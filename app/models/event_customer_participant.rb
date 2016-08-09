class EventCustomerParticipant < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail
  include SaleMixin

  EVENT_TYPES = [:transports, :additionals, :kit_hire, :insurance]

  has_many :event_customer_participant_options, class_name: 'EventCustomerParticipantOptions::EventCustomerParticipantOption'
  has_one :event_customer_participant_insurance, class_name: 'EventCustomerParticipantOptions::Insurance', dependent: :destroy
  has_one :event_customer_participant_kit_hire, class_name: 'EventCustomerParticipantOptions::KitHire', dependent: :destroy
  has_many :event_customer_participant_additionals, class_name: 'EventCustomerParticipantOptions::Additional', dependent: :destroy
  has_many :event_customer_participant_transports, class_name: 'EventCustomerParticipantOptions::Transport', dependent: :destroy

  has_one :event_customer_participant_discount, as: :discountable, class_name: "Discount", dependent: :destroy

  has_many :transports, through: :event_customer_participant_transports
  has_many :additionals, through: :event_customer_participant_additionals

  has_one :kit_hire, through: :event_customer_participant_kit_hire
  has_one :insurance, through: :event_customer_participant_insurance

  has_one :sale_product, as: :sale_productable, dependent: :destroy
  has_one :sale, through: :sale_product

  belongs_to :event, with_deleted: true
  belongs_to :customer, with_deleted: true
  belongs_to :event_user_participant

  with_options allow_destroy: true do |ad|
    ad.accepts_nested_attributes_for :event_customer_participant_transports
    ad.accepts_nested_attributes_for :event_customer_participant_additionals
    ad.accepts_nested_attributes_for :event_customer_participant_kit_hire, reject_if: :kit_hire_attrs_blank?
    ad.accepts_nested_attributes_for :event_customer_participant_insurance, reject_if: :insurance_attrs_blank?
    ad.accepts_nested_attributes_for :event_customer_participant_discount
  end

  validates :event, presence: true
  validates :customer, presence: true, if: ->(u){ u.group_name.blank? && u.quantity.blank? }
  validates :group_name, presence: true, length: { maximum: 255 }, if: ->(u){ u.customer.blank? }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :event_user_participant, existence: { allow_nil: true }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :nitrox, numericality: { greater_than_or_equal_to: 0 }
  validates :note, length: { maximum: 65536 }

  validate :check_limit_of_registrations, on: :create

  scope :unpaid,                ->{ includes(:sale).where( sale: { id: nil } ) }
  scope :for_event,             ->(event_id){ where(event_id: event_id) }
  scope :not_assigned_to_staff, ->{ where(event_user_participant_id: nil) }
  scope :by_ecp_id,             ->(ecp_id){ where(id: ecp_id) if ecp_id }
  scope :pending,               ->{ where(status: "pending") }
  scope :need_show,             ->{ where(need_show: true).order("created_at desc") }
  scope :not_refunded,          ->{ joins(:sale).where{ (sale.status.not_in Sale::REFUND_STATUSES ) } }
  scope :ordered,               ->{ order('created_at DESC') }

  attr_accessor :customer_email, :want_pay

  attr_accessible :local_event, :event_id, :event_user_participant_id, :event_customer_participant_kit_hire_attributes,
                  :event_customer_participant_insurance_attributes, :nitrox,
                  :event_customer_participant_transports_attributes, :event_customer_participant_additionals_attributes,
                  :customer_id, :sale_id, :event_customer_participant_discount_attributes, :price, :original_id,
                  :need_show, :reject, :note, :group_name, :quantity, :contact_information

  before_validation :detect_customer, on: :create
  before_validation :set_group_and_customers
  before_validation :calculate_price
  before_create :add_status_if_bookings_and_want_pay
  after_create :add_ecps_to_children_course_events
  after_create :approve

  after_save :send_notification_email

  EVENT_TYPES.each do |event_type|
    # :transports_attrs_blank?
    define_method "#{event_type.to_s}_attrs_blank?" do |attrs|
      return false if !attrs["free"].to_i.zero?
      attrs["id"].to_i.zero? &&  attrs["#{event_type.to_s.singularize}_id"].blank?
    end

    # :transports_price
    define_method "#{event_type.to_s}_price" do
      get_amount_for(event_type, :line_item)
    end
  end

  def grand_total_price
    list = []
    %w(kit_hire transports additionals insurance).each do |method|
      list << send("event_customer_participant_#{method}")
    end
    list.flatten.compact.map(&:line_item_price).sum + event_line_item_with_discount + event.material_price
  end

  def line_item_price_with_tax_rate
    grand_total_price + if event.store.tax_rate_inclusion?
                          0
    else
      full_tax_rate_amount
    end
  end

  def calc_discount
    (event_unit_price * customer.try(:default_discount_level).to_f / 100) +
     event_customer_participant_options.map(&:line_item_discount).sum
  end

  def apply_overlall_discount
    event_unit_price * sale.discount.value.to_f / 100 + event_customer_participant_options.map(&:apply_overlall_discount).sum
  end

  def event_unit_price
    event.unit_price(customer)
  end

  def event_material_price
    event.material_price
  end

  def event_tax_rate_amount
    return 0 if customer && customer.try(:zero_tax_rate?)
    event.tax_rate_amount(customer, event_line_item_with_discount)
  end

  def event_tax_rate_amount_line
    return 0 if customer && customer.try(:zero_tax_rate?)
    event.tax_rate_amount_line(customer)
  end

  def event_line_item_price
    event.line_item_price(customer)
  end

  def event_line_item_price_with_tax_rate
    event_line_item_price + if event.store.tax_rate_inclusion?
                              0
    else
      event.tax_rate_amount_line(customer)
    end
  end

  def event_line_item_with_discount
    self.event_customer_participant_discount.try(:apply, event_unit_price) || (sale && sale.discount.try(:apply, event_unit_price)) || event_unit_price
  end

  def full_tax_rate_amount
    return 0 if customer && customer.try(:zero_tax_rate?)
    event_customer_participant_options.map(&:reload).map(&:tax_rate_amount).sum + event_tax_rate_amount + event.material_price_tax
  end

  def grand_total_price_with_default_discount
    grand_total_price - grand_total_price * customer.try(:default_discount_level).to_f / 100
  end

  def sub_total
    event_line_item_with_discount
  end

  def can_be_refunded?
    refunded.empty?
  end

  def unpaid?
    sale.nil?
  end

  def unique_grouped_transports
    self.grouped_transports.values.map(&:first)
  end

  def grouped_transports
    self.event_customer_participant_transports.group_by(&:transport_id)
  end

  def customer_list_for_sale_card
    self.event.event_customer_participants.unpaid.map(&:customer)
  end

  def attrs_for_clone
    { event_id: self.event_id, customer_id: self.customer_id,
      event_user_participant_id: self.event_user_participant_id,
      price: self.price, original_id: self.id }
  end

  def clone_childs original_ecp
    self.clone_discount(original_ecp.discount)

    original_ecp.child_associations.each do |child|
      if child.kit_hire_or_insurance?
        self.send("build_#{child.nested_attribute_name}", child.attrs_for_clone)
      else
        self.send(child.nested_attribute_name).send("build", child.attrs_for_clone)
      end.clone_discount(child.discount)
    end
  end

  def child_associations
    EVENT_TYPES.map{ |type| self.send("event_customer_participant_#{type}") }.flatten.compact
  end

  def approve
    update_attributes need_show: false
    return unless customer
    return unless customer.send_event_related_emails?
    if sale
      sale.send_bookings_paid_emails
    else
      return if event.course? && !event.parent?
      SaleMailer.delay.send_bookings_not_paid_email_for_customer_approved(self)
    end
  end

  def create_refund_sale_list
    sale.refund!(ecp_id: id, sale_product_id: sale_product.id)
  end

  def not_refunded?
    ecp_sale_product = SaleProduct.where(sale_productable_type: 'EventCustomerParticipant', sale_productable_id: id).first
    return self if ecp_sale_product.nil? || ( ecp_sale_product.sale && !ecp_sale_product.sale.refunded?)
    nil
  end

  def show_event_customer_participant_transpost
    return "-" if event_customer_participant_transports.blank?
    "#{event_customer_participant_transports.first.try(:information)} - #{event_customer_participant_transports.first.try(:only_time)} "
  end

  def show_discount
    "#{customer.default_discount_level}% (#{customer.full_name})" if customer
  end

  def send_bookings_not_paid_emails
    SaleMailer.delay.send_bookings_not_paid_email_for_customer(self) if customer.send_event_related_emails?
    SaleMailer.delay.send_bookings_not_paid_email_for_store(self)
  end

  def send_bookings_paid_emails
    SaleMailer.delay.send_bookings_email_for_customer( sale, self ) if customer.send_event_related_emails?
    SaleMailer.delay.booking_online_for_shop( sale, self)
  end

  ########################## FOR MOVE ECPS #####################################
  def unit_price
    event.unit_price(customer)
  end

  def tax_rate_amount
    event.tax_rate_amount(customer)
  end

  def class_type
    self.class.name
  end

  def logo
    nil
  end

  def sku_code
    nil
  end

  def dynamic_quantity
    customer ? 1 : self[:quantity]
  end

  private
  #FIXME: use :child_associations method
  def get_amount_for(event_type, method)
    ecp_type = self.send(event_type.eql?(:transports) ? "unique_grouped_transports" : "event_customer_participant_#{event_type}")
    ecp_type.is_a?(Array) ? ecp_type.map(&method.to_sym).sum : ecp_type.try(method.to_sym).to_f
  end

  def get_total_options_amount_by(method)
    EVENT_TYPES.map { |event_type| get_amount_for(event_type, method) }.compact.sum
  end

  def detect_customer
    self.customer_id = event.store.company.customers.find_by_email(self.customer_email).try(:id) if customer_email.present?
  end

  def add_status_if_bookings_and_want_pay
    self.status = "pending" if customer_email.present? and want_pay.present? and want_pay == "true"
  end

  def calculate_price
    return unless event
    self.price = self.grand_total_price
  end

  def check_limit_of_registrations
    return if event.blank? || event.limit_of_registrations.blank? || sale.try(:refund?)
    errors.add(:base, I18n.t('models.event_customer_participant,exceeded_limit')) if event.limit_of_registrations <= event.event_customer_participants.select{ |ecp| ecp.not_refunded? }.count
  end

  def add_ecps_to_children_course_events
    return if !event || ( event && ( !event.course? || !event.parent? ) )
    event.children.each do |event|
      ecp = self.dup
      ecp.event_user_participant_id = EventUserParticipant.find_by_event_id_and_user_id(event.id, event_user_participant.user.id).id if event_user_participant
      ecp.event_id = event.id
      ecp.price = 0 if event.course? && !event.parent?
      ecp.save(validate: false)
    end
  end

  def set_group_and_customers
    if customer
      self.group_name = nil
      self.quantity = 1
    else
      self.customer_id = nil
    end
  end

  def send_notification_email
    event.users.where.not(email: nil).each do |user|
      SaleMailer.delay.send_update_ecp_email( self, user.email )
    end

    event.customers.where.not(email: nil).each do |customer|
      SaleMailer.delay.send_update_ecp_email( self, customer.email )
    end
  end
end
