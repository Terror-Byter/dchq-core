class Event < ActiveRecord::Base
  include PgSearch

  pg_search_scope :search, against: [:name],
                           using: {
                             tsearch: {prefix: true, any_word: true },
                             trigram: { } },
                           ignoring: :accents
  has_paper_trail
  acts_as_paranoid

  belongs_to :store
  belongs_to :boat, class_name: "Stores::Boat"
  belongs_to :event_type

  has_many :event_customer_participant_transports, through: :event_customer_participants
  has_many :customer_participants, class_name: "EventCustomerParticipant"
  has_many :sales, through: :event_customer_participants
  has_many :customers, through: :event_customer_participants

  has_many :event_user_participants
  has_many :event_customer_participants

  has_many :users, through: :event_user_participants

  attr_accessible :name, :event_type_id, :certification_level_id, :event_trip_id, :starts_at, :ends_at,
                  :additional_equipment, :price, :private, :store_id, :frequency, :created_at, :updated_at,
                  :parent_id, :notes, :enable_booking, :limit_of_registrations, :location,
                  :instructions, :cancel, :boat_id, :number_of_frequencies, :number_of_dives, :type,
                  :event_user_participants_attributes


  with_options allow_destroy: true do |o|
    o.accepts_nested_attributes_for :event_customer_participants, reject_if: ->(u){ u[:customer_email].blank? }
    o.accepts_nested_attributes_for :event_user_participants
  end

  validates :boat, existence: { allow_blank: true }
  validates :store, presence: true
  validates :starts_at, presence: true, timeliness: { type: :datetime, on_or_before: :ends_at }
  validates :ends_at,   presence: true, timeliness: { type: :datetime }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :additional_equipment, length: { maximum: 255 }, allow_blank: true
  validates :limit_of_registrations, numericality: { greater_than_to: 0 }, allow_blank: true
  validates :cancel, inclusion: { in: [true, false] }
  validates :number_of_dives, numericality: { greater_than_or_equal_to: 0 }
  validates :event_type, presence: true

  scope :visible,      ->{ where(private: true) } #todo: fix as this is inverted for public calendar
  scope :unassigned,   ->{ where(boat_id: nil) }
  scope :with_costs,   ->{ where{ price.gt 0 } }
  scope :future,       ->{ where("starts_at >= ?", Time.current.beginning_of_day).order(:starts_at) }
  scope :not_those,    ->(event_ids){ where{ id.not_in event_ids } }
  scope :for_boat,     ->(boat_ids){ where(boat_id: boat_ids) }
  scope :courses,      ->{ where(type: 'CourseEvent') }
  scope :other_events, ->{ where(type: 'OtherEvent') }

  scope :time_period, ->(event_start, event_end){
    where{
      ((starts_at.gt event_start) & (starts_at.lt event_end)) |
      ((ends_at.gt event_start) & (ends_at.lt event_end)) |
      ((starts_at.lt event_start) & (ends_at.gt event_end))
    }
  }

  scope :events_time, ->(time){
    case time
    when "day", nil then
      event_start = Time.current.beginning_of_day
      event_end = Time.current.end_of_day
    when "tomorrow" then
      event_start = Time.current.beginning_of_day.tomorrow
      event_end = Time.current.end_of_day.tomorrow
    when 'after_tomorrow' then
      event_start = Time.current.beginning_of_day.tomorrow + 1.days
      event_end   = Time.current.end_of_day.tomorrow + 1.days
    when "week" then
      event_start = Time.current.beginning_of_week
      event_end = Time.current.end_of_week
    when "week_later" then
      event_start = Time.current
      event_end = Time.current.end_of_week
    when "month" then
      event_start = Time.current.beginning_of_month
      event_end = Time.current.end_of_month
    when "next_month" then
      event_start = Date.current.beginning_of_month.next_month
      event_end = Date.current.end_of_month.next_month
    when "quarter" then
      event_start = Date.current.beginning_of_quarter
      event_end = Date.current.end_of_quarter
    end

    where{
      ((starts_at.gt event_start) & (starts_at.lt event_end)) |
      ((ends_at.gt event_start) & (ends_at.lt event_end)) |
      ((starts_at.lt event_start) & (ends_at.gt event_end))
    }
  }

  def distance_in_days
    days = (ends_at - starts_at) / 3600 / 24
    if days < 1 and days >= 0
      1
    else
      days.round
    end
  end

  def available?
    self.starts_at >= Time.current.beginning_of_day
  end

  def available_places
    return 1000000 if limit_of_registrations.blank?
    limit_of_registrations - event_customer_participants.select{ |u| u.not_refunded? }.sum(&:dynamic_quantity)
  end

  def in_the_past?
    self.starts_at < Time.now
  end

  def make_cancel
    self.update_attribute :cancel, true
  end

  def no_registrations?
    event_customer_participants.blank?
  end

  def no_payments?
    !no_registrations? && sales.completed.blank?
  end

  def can_change?
    !self.cancel?
  end

  def notify_customer(customers = [], message = "")
    customers.each do |customer|
      CompanyMailer.delay.event_cancelled_no_payments(customer, self, message)
    end
  end

  def get_refunded_event_customer_participants
    sales.refund_complete{ |sale| sale.event_customer_participants }.flatten
  end

  def get_paid_event_customer_participants
    sales.completed.map{ |sale| sale.event_customer_participants }.flatten
  end

  def full_name
    "#{name} on #{starts_at.in_time_zone(store.time_zone).strftime("%a, #{starts_at.day.ordinalize} %B, %Y")}"
  end

  alias_attribute :label, :full_name

  def event_short_time
    "#{I18n.l(starts_at, formats: :default)} - #{I18n.l(ends_at, formats: :default)}"
  end

  def material_price
    mat_price = store.certification_level_costs.find_by_certification_level_id(certification_level_id).try(:material_price)
    return 0 if mat_price.nil? || ( course? && !parent? )
    material_tax = mat_price.tax_rate.amount.to_f / 100
    if store.tax_rate_inclusion?
      mat_price.price + mat_price.price.to_f / (mat_price.tax_rate.amount.to_f / 100 + 1) * material_tax
    else
      mat_price.price + mat_price.price.to_f * material_tax
    end
  end

  def calc_dive_equipment size, equip_type
    numbers = customers.where{(:"#{equip_type}".eq size) & ((:"#{equip_type}_own".eq false) | (:"#{equip_type}_own".eq nil))}.count
    numbers.zero? ? "-" : numbers
  end

  def calc_rent_masks
    numbers = customers.where{(mask_own.eq false) | (mask_own.eq nil)}.count
    numbers.zero? ? "-" : numbers
  end

  def calc_total_weight
    customers.map{|u| u.weight.to_f}.sum
  end

  def trip?
    type.eql?('OtherEvent') && event_trip
  end

  def event_time
    "#{I18n.l(starts_at, format: :default).capitalize} - #{I18n.l(ends_at, format: :default).capitalize}"
  end

  def course?
    type.eql?("CourseEvent")
  end

  def unit_price customer = nil
    mat_price = store.certification_level_costs.find_by_certification_level_id(certification_level_id).try(:material_price)
    return 0 if price.blank?
    return mat_price ? (price - mat_price.try(:price).to_f) : price unless trip?
    customer.try(:has_local_tag?) ? event_trip.local_price_without_tax_rate : price
  end

  def tax_rate_amount customer = nil, cost = 0
    return 0 if (!trip? && !course?) || (course? && recurring_child?)
    if trip?
      event_trip.tax_rate.amount
    elsif course?

      course = store.certification_level_costs.find_by_certification_level_id(certification_level_id)
      return 0 unless course
      course.tax_rate.amount
    else
      0
    end
  end

  def tax_rate_amount_line customer = nil
    return 0 if (!trip? && !course?) || (course? && recurring_child?)
    if trip?
      event_trip.tax_rate.amount

    elsif course?

      course = store.certification_level_costs.find_by_certification_level_id(certification_level_id)
      return unless course
      course.try(:tax_rate).try(:amount)
    else
      0
    end
  end

  def material_price_tax
    mat_price = store.certification_level_costs.find_by_certification_level_id(certification_level_id).try(:material_price)

    return 0 if mat_price.blank? || ( mat_price && mat_price.price.blank? )
    course_tax = mat_price.tax_rate.amount.to_f / 100
    if store.tax_rate_inclusion?
      return mat_price.price / (course_tax + 1) * course_tax
    else
      return mat_price.price * course_tax
    end
  end


  def line_item_price customer
    price = unit_price(customer)
    if store.tax_rate_inclusion?
      price
    else
      price + tax_rate_amount(customer)
    end
  end

  def can_be_deleted?
    event_customer_participants.empty? && event_user_participants.empty?
  end

  def recurring?
    recurring_child? || recurring_parent?
  end

  def recurring_child?
    !parent_id.blank?
  end

  def recurring_parent?
    return true unless Event.where(store_id: store_id, parent_id: id).blank?
    false
  end

  def available_staffs
    available_staffs = self.store.company.available_for_event_users(self)
    available_staffs << self.event_user_participants.map(&:user)
    available_staffs.flatten.uniq.map{ |u| [u.full_name, u.id] }
  end
end
