class Service < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper
  include PgSearch
  include AASM

  pg_search_scope :search, against: [:kit, :serial_number, :barcode],
                           using: {
                             tsearch: {prefix: true, any_word: true },
                             trigram: { } },
                           ignoring: :accents

  acts_as_taggable
  has_paper_trail

  belongs_to :store
  belongs_to :customer, unscoped: true
  belongs_to :user, unscoped: true
  belongs_to :sale

  has_many :service_notes, as: :notable, class_name: "Services::ServiceNote", dependent: :destroy
  has_many :service_items, class_name: "Services::ServiceItem", dependent: :destroy
  has_many :products, through: :service_items
  has_many :time_intervals, class_name: "Services::TimeInterval", dependent: :destroy
  has_many :attachments, through: :service_notes
  has_many :kits, class_name: 'Services::Kit'

  attr_accessible :service_notes_attributes, :terms_and_conditions, :customer_id, :user_id,
                  :collection_date, :complimentary_service, :service_items_attributes,
                  :sale_id, :status, :kits_attributes

  accepts_nested_attributes_for :service_items, allow_destroy: true
  accepts_nested_attributes_for :service_notes, reject_if: ->(pm){ pm[:description].blank? }
  accepts_nested_attributes_for :kits

  with_options presence: true do |v|
    v.validates :store_id
    v.validates :customer
    v.validates :user
    v.validates :booked_in, timeliness: { type: :date }
    v.validates :collection_date, timeliness: { type: :date }
  end
  validate :check_terms_and_conditions, on: :create

  attr_accessor :terms_and_conditions

  scope :current_month, -> { where( created_at: Time.now.beginning_of_month .. Time.now) }
  scope :booked_for_current_month, -> { booked.current_month }
  scope :in_progress_for_current_month, -> { in_progress.current_month }
  scope :awaiting_collection_for_current_month, -> { awaiting_collection.current_month }
  scope :complete_for_current_month, -> { complete.current_month }

  aasm column: 'status', skip_validation_on_save: true do
    state :booked, initial: true
    state :in_progress
    state :awaiting_collection
    state :complete

    event :to_in_progress do
      transitions from: :booked, to: :in_progress
    end

    event :to_awaiting_collection do
      transitions from: [:in_progress, :booked], to: :awaiting_collection
    end

    event :to_complete do
      transitions from: [:awaiting_collection, :booked, :in_progress], to: :complete
    end
  end

  def unit_price
    0
  end

  def tax_rate_amount
    0
  end

  def sub_total_price
    store.tax_rate_inclusion? ? grand_total : grand_total - full_tax_rate_amount
  end

  def full_tax_rate_amount
    return 0 if complimentary_service || type_of_services.empty?
    type_of_services_total_taxes + products.map(&:tax_rate_amount).sum
  end

  def type_of_services
    kits.map(&:type_of_service).compact
  end

  def type_of_services_total_taxes
    kits.inject(0) do |result, kit|
      result += kit.type_of_service.tax_rate_amount
      result += kit.type_of_service.service_kit.try(:tax_rate_amount).to_f
    end
  end

  def type_of_services_total
    kits.inject(0) do |result, kit|
      result += kit.type_of_service.try(:line_item_price).to_f
      result += kit.type_of_service.try(:service_kit).try(:line_item_price).to_f
    end
  end

  def grand_total
    return 0 if complimentary_service
    type_of_services_total + products.map(&:line_item_price).sum
  end

  def calculate_time_intervals
    seconds = 0
    time_intervals.complete.each do |time_interval|
      seconds += (time_interval.ends_at.to_f - time_interval.starts_at.to_f).to_i
    end
    seconds += (Time.now.to_f - time_intervals.last.starts_at.to_f).to_i unless time_intervals.in_progress.blank?
    seconds
  end

  def next_step
    aasm.states(:permissible => true).map(&:name).first
  end

  def jump_to_next_step!
    send("to_#{next_step}!") if next_step
  end

  def continue?
    !time_intervals.in_progress.blank? and in_progress?
  end

  def update_sale_id! sale
    self.update_attributes sale_id: sale.id
  end

  def class_type
    self.class.name
  end

  def logo
    return "servicing-no-image.png" if attachments.blank? or attachments.images.blank?
    attachments.images.first.data.url
  end

  def sku_code
    ''
  end

  def name
    "#{ I18n.t('models.service.servicing') }: #{kit} #{serial_number}"
  end

  def number_in_stock
    1
  end

  def pay_status
    return I18n.t('models.service.paid') if sale.try(:status) == "complete"
    "#{ number_to_currency grand_total, precision: store.currency.precision, unit: store.currency.unit }".html_safe
  end

  private
  def check_terms_and_conditions
    errors.add(:base, I18n.t('models.service.confirm_term')) if terms_and_conditions != "1"
  end
end
