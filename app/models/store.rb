class Store < ActiveRecord::Base
  has_paper_trail
  include CurrentUserInfo

  belongs_to :company
  belongs_to :currency

  has_and_belongs_to_many :users

  has_many :certification_levels
  has_many :certification_level_costs
  has_many :payment_methods
  has_many :tax_rates
  has_many :commission_rates
  has_many :event_trips
  has_many :events
  has_many :course_events
  has_many :other_events
  has_many :event_customer_participants, through: :sales
  has_many :customer_participants, through: :events
  has_many :boats, class_name: "Stores::Boat"
  has_many :events_with_boats, through: :boats, source: :events, order: :starts_at
  has_many :working_times, class_name: "Stores::WorkingTime"
  has_many :event_tariffs, class_name: "Stores::EventTariff"
  has_many :finance_reports, class_name: "Stores::FinanceReport"
  has_many :invoices, class_name: "Stores::Invoice"
  has_many :credits, class_name: "Stores::Credit"
  has_one :email_setting, class_name: "Stores::EmailSetting"

  has_many :kit_hires, class_name: "ExtraEvents::KitHire"
  has_many :transports, class_name: "ExtraEvents::Transport"
  has_many :insurances, class_name: "ExtraEvents::Insurance"
  has_many :additionals, class_name: "ExtraEvents::Additional"

  has_many :type_of_services, class_name: "Services::TypeOfService"
  has_many :service_kits, class_name: "Services::ServiceKit"
  has_many :services
  has_many :categories
  has_many :brands
  has_many :products
  has_many :miscellaneous_products
  has_many :sales
  has_many :sale_customers, through: :sales
  has_many :sale_products, through: :sales
  has_many :credit_notes, through: :sales
  has_many :tills, dependent: :destroy
  has_many :sold_products, through: :sales, source: :products do
    def week_ago
      where(sale_products: { :created_at.gt => 1.week.ago })
    end

    def brand_ids
      select("DISTINCT(brand_id)")
    end

    def category_ids
      select("DISTINCT(category_id)")
    end
  end
  has_many :payments, through: :sales
  has_many :rental_products
  has_many :rentals
  has_many :renteds, through: :rentals
  has_one :xero, class_name: "Stores::Xero"
  has_one :scuba_tribe, class_name: 'Stores::ScubaTribe'
  has_one :avatar, as: :imageable, class_name: "Image", dependent: :destroy

  accepts_nested_attributes_for :avatar, allow_destroy: true
  accepts_nested_attributes_for :email_setting
  with_options allow_destroy: true do |ad|
    ad.accepts_nested_attributes_for :type_of_services, reject_if: ->(pm){ pm[:name].blank? }
    ad.accepts_nested_attributes_for :boats
    ad.accepts_nested_attributes_for :service_kits, reject_if: ->(pm){ pm[:name].blank? }
    ad.accepts_nested_attributes_for :payment_methods, reject_if: ->(pm){ pm[:name].blank? }
    ad.accepts_nested_attributes_for :event_tariffs, reject_if: ->(pm){ pm[:name].blank? }
    ad.accepts_nested_attributes_for :xero
    ad.accepts_nested_attributes_for :finance_reports
    ad.accepts_nested_attributes_for :tills

    ad.with_options reject_if: ->(rate){ rate[:amount].blank? } do |ri|
      ri.accepts_nested_attributes_for :tax_rates
      ri.accepts_nested_attributes_for :commission_rates
    end

    ad.accepts_nested_attributes_for :certification_levels, reject_if: ->(pm){ pm[:name].blank? }
    ad.with_options reject_if: ->(pricing){ pricing[:name].blank? && pricing[:cost].blank? } do |ri|
      ri.accepts_nested_attributes_for :event_trips

      ri.accepts_nested_attributes_for :kit_hires
      ri.accepts_nested_attributes_for :transports
      ri.accepts_nested_attributes_for :insurances
      ri.accepts_nested_attributes_for :additionals
    end
  end

  with_options presence: true do |o|
    o.validates :company
    o.validates :name, length: { maximum: 255 }
    o.validates :location
    o.validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }
    o.validates :currency
    o.validates :public_key, uniqueness: true
    o.validates :api_key, uniqueness: true
    o.validates :printer_type, inclusion: { in: ->(s){ Store.printer_types.keys } }
    o.validates :calendar_type, inclusion: { in: ->(s){ Store.calendar_types.keys } }
    #TODO add to tests
    o.validates :tsp_url, if: ->(u){ u.printer_type.eql?('tsp') }
    o.validate :invoice_id, unless: ->(u){ u.main }
  end
  validates :standart_rental_term, length: { maximum: 65536 }
  validates :calendar_header, length: { maximum: 65536 }
  validates :calendar_footer, length: { maximum: 65536 }
  validates :invoice_title, length: { maximum: 255 }
  validates :receipt_title, length: { maximum: 255 }
  validates :initial_receipt_number, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  scope :extra, ->{ where(main: false) }
  #TODO Remek scope
  scope :enable_low_inventory_email, ->{ joins(:email_setting).where( email_setting: { disable_low_inventory_product_reminder_email: false } ) }

  attr_accessible :company_id, :name, :location, :currency, :currency_id, :printer_type, :time_zone, :main,
                  :invoice_id, :calendar_type, :standart_term, :barcode_printing_type, :tax_rate_inclusion,
                  :email_setting_attributes, :type_of_services_attributes, :boats_attributes,
                  :service_kits_attributes, :payment_methods_attributes, :event_tariffs_attributes,
                  :avatar_attributes, :xero_attributes, :tax_rates_attributes, :commission_rates_attributes,
                  :certification_levels_attributes, :event_trips_attributes, :transports_attributes,
                  :insurances_attributes, :kit_hires_attributes, :additionals_attributes, :tsp_url,
                  :finance_reports_attributes, :tills_attributes, :standart_rental_term, :invoice_title, :receipt_title,
                  :calendar_header, :calendar_footer, :initial_receipt_number

  class << self
    def calendar_types
      {"agendaDay"  => I18n.t('models.store.calendar_type.day'),
       "agendaWeek" => I18n.t('models.store.calendar_type.week'),
       "month"      => I18n.t('models.store.calendar_type.month') }
    end

    def printer_types
     {
       "80mm" => I18n.t('models.store.printer_types.80mm'),
       "70mm" => I18n.t('models.store.printer_types.70mm'),
       "tsp"  => I18n.t('models.store.printer_types.tsp')
     }
    end

    def barcode_printing_type
      { a4:    I18n.t('models.store.barcode_printing_types.a4'),
        zebra: I18n.t('models.store.barcode_printing_types.zebra') }
    end
  end

  def all_events type
    events = []
    if type == 'all_events' || type == 'additionals'
      events += additionals.with_costs
      events += insurances.with_costs
      events += kit_hires.with_costs
      events += transports.with_costs
    end
    if type == 'all_events' || type == 'certification_levels'
      events += get_certification_levels_with_costs
    end
    if type == 'all_events' || type == 'trips'
      events += event_trips.with_costs
    end
    events.sort{|a,b| a['name'] <=> b['name']}
  end

  before_validation :generate_keys, on: :create
  before_validation :smart_add_tsp_url_protocol
  after_create :create_requirements
  before_destroy :check_main_store
  after_destroy :destroy_all_childrens, :remove_invoice

  def tax_rates_list
    tax_rates.map{ |tr| [tr.amount, tr.id] }
  end

  def commission_rates_list
    commission_rates.map{ |cr| [cr.amount, cr.id] }
  end

  def line_chart
    grouped_sales = sales.completed_for_current_month.group_by{ |s| "#{s.created_at.month}-#{s.created_at.day}" }
    trend_data = date_interval.map.with_index{ |d, index| [index+1, grouped_sales[d] ? grouped_sales[d].map(&:grand_total).sum.to_f.round(2) : 0.0] }
    trend_data
  end

  def get_certification_levels_with_costs
    certification_levels.with_cost
  end

  def search_events q
    result = events.search(q).map{|u| {name: "#{u.name} (#{u.event_short_time})", type: u.class.name.downcase, id: u.id }}
    result += products.search(q).map{|u| {name: "#{u.name} (#{u.sku_code})", type: u.class.name.downcase, id: u.id }}
    result += services.search(q).map{|u| {name: "#{u.kit} (#{u.serial_number})".truncate(30), type: u.class.name.downcase, id: u.id }}
  end

  def get_credit_note_payment_method
    payment_methods.find_by_name("Credit Note")
  end

  def has_service_settings?
    !type_of_services.blank?
  end

  def sale_products_for_current_month_in_numbers
    sale_products.where(sale_id: sales_per_current_month).only_products.count
  end

  def sale_services_for_current_month_in_numbers
    sale_products.where(sale_id: sales_per_current_month).only_services.count
  end

  def sale_events_for_current_month_in_numbers
    @sale_events_for_current_month_in_number ||= sale_products.where(sale_productable_type: 'EventCustomerParticipant', sale_id: sales_per_current_month).count
  end

  def rentals_for_current_month_in_numbers
    @rentals_for_current_month_in_numbers ||= renteds.where(rental_id: rentals_per_current_month).count
  end

  def total_sales_for_current_month_in_numbers
    sale_events_for_current_month_in_numbers +
      sale_products.where(sale_id: sales_per_current_month).count +
      rentals_for_current_month_in_numbers
  end

  def sale_products_for_current_month_in_percentage
    return 0 if total_sales_for_current_month_in_numbers.zero?
    sale_products_for_current_month_in_numbers * 100 / total_sales_for_current_month_in_numbers
  end

  def sale_events_for_current_month_in_percentage
    return 0 if total_sales_for_current_month_in_numbers.zero?
    sale_events_for_current_month_in_numbers * 100 / total_sales_for_current_month_in_numbers
  end

  def sale_services_for_current_month_in_percentage
    return 0 if total_sales_for_current_month_in_numbers.zero?
    sale_services_for_current_month_in_numbers * 100 / total_sales_for_current_month_in_numbers
  end

  def rentals_for_current_month_in_percentage
    return 0 if total_sales_for_current_month_in_numbers.zero?
    rentals_for_current_month_in_numbers * 100 / total_sales_for_current_month_in_numbers
  end

  def generate_sale_targets_for_chart
    data = []
    sales_completed = sales.completed.for_this_period(Date.today.beginning_of_month)

    company.users.where(sale_target_show_dashboard: true).each do |user|
      data << [[user.sale_target.to_f, sales_completed.select{ |s| s.creator_id == user.id }.map(&:grand_total).sum.to_f], user.full_name ]
    end
    data
  end

  def close?
    add_working_time if working_times.blank?
    !working_times.last.close_at.blank?
  end

  def closed_info
    working_time = working_times.last
    {user_full_name: working_time.closed_user.full_name, time: working_time.close_at, open_time: working_time.open_at }
  end

  def xero_connected?
    create_xero if xero.blank?
    return false if xero.xero_consumer_key.blank? or xero.xero_consumer_secret.blank?
    true
  end

  def scubatribe_connected?
    !!scuba_tribe.try(:api_key)
  end

  def send_product_reminder_email
    products_list = products.need_to_remind
    StoreMailer.delay.remind_product(self, products_list)
    products_list.update_all(sent_at: Time.now)
  end

  def set_close!
    @working_time = working_times.last
    transaction do
      @working_time.update_attributes close_at: Time.now, closed_user: current_user_info
      generate_invoice
      generate_credit
    end
    close?
  end

  def reopen!
    working_time = working_times.last
    return unless working_time.open_at.today?

    transaction do
      working_time.tap do |w|
        w.close_at = nil
        w.closed_user = nil
        w.opened_user = current_user_info
        w.save(validate: false)
      end
      working_time.finance_report.each do |report|
        if report.sent?
          xero = Xero.new(self)
          xero.delete_report(report)
        end
        report.destroy
      end
    end
  end

  def average_sale_per_customer
    customers_count = customes_with_sales_this_month
    customers_count = customers_count.eql?(0) ? 1 : customers_count
    revenue_this_month.to_f / customers_count
  end

  def services_complete_this_month
    services.complete.where(created_at: Time.now.beginning_of_month .. Time.now).count
  end

  def revenue_this_month
    sales.sales_without_refunded_childs_per_month.sum(:grand_total)
  end

  def event_registrations_this_month
    event_customer_participants.where(created_at: Time.now.beginning_of_month .. Time.now).count
  end

  def customers_this_month
    customer_participants.where(created_at: Time.now.beginning_of_month .. Time.now).count
  end

  def has_epay_payment_method?
    !payment_methods.where(name: 'Epay').blank?
  end

  private
  def sales_per_current_month
    @sales_per_current_month ||= sales.completed_for_current_month
  end

  def rentals_per_current_month
    @rentals_per_current_month ||= rentals.completed_for_current_month
  end

  def customes_with_sales_this_month
    SaleCustomer.where(sale_id: sales_per_current_month).uniq.count
  end

  def total_store_revenue
    sales.sales_without_refunded_childs_all_time.sum(:grand_total)
  end

  def create_requirements
    create_default_sales
    add_managers_to_store
    add_payment_methods
    add_working_time
    add_email_settings
  end

  def date_interval
    (Date.today.beginning_of_month.to_date..Date.today).to_a.map{|d| "#{d.month}-#{d.day}"}
  end

  def generate_keys
    self.public_key = Digest::SHA2.hexdigest("#{Time.now}--#{self.name}")
    self.api_key    = Digest::SHA2.hexdigest("#{Time.now}--#{self.name}")
  end

  def company_should_has_one_or_more_stores
    if company.stores.count < 2
      errors.add(:base, I18n.t('models.store.company_error'))
      false
    end
  end

  def destroy_all_childrens
    PurchaseOrder.destroy_all(delivery_location_id: id)
    [Stores::Boat, Brand, Category, CertificationLevelCost, CertificationLevel, CommissionRate, Stores::EmailSetting,
     Stores::EventTariff, EventTrip, Event, ExtraEvents::ExtraEvent, Stores::FinanceReport, MiscellaneousProduct,
     PaymentMethod, Rental, Sale, Services::ServiceKit, Service, StoreProduct, TaxRate, Services::TypeOfService, Till,
     Stores::WorkingTime, Stores::Xero].map{|u| u.destroy_all(store_id: id)}
  end

  def add_managers_to_store
    unless on_migration
      company.staff_members.manager.each do |manager|
        manager.stores << self
        manager.save
      end
    end
  end

  def add_working_time
    self.working_times.create open_at: Time.now, opened_user: company.owner
  end

  def create_default_sales
    tax_rates.create amount: 0.0
    commission_rates.create amount: 0.0
  end

  def add_managers_to_store
    company.users.managers.each do |user|
      user.stores << self
      user.save
    end
  end

  def add_payment_methods
    payment_methods.create [{ name: 'Paypal' }, { name: 'Credit Card' }, { name: 'Cash'}]
  end

  def check_main_store
    call_stack = caller.join("!").include?("update_stores")
    return !self.main if call_stack
    return true
  end

  def remove_invoice
    return if main or invoice_id.blank?
    Stripe.api_key = Figaro.env.stripe_api_key
    ii = Stripe::InvoiceItem.retrieve(invoice_id)
    ii.delete
  end

  def add_email_settings
    self.create_email_setting
  end

  def generate_invoice
    @complete_sales = sales.for_invoice(@working_time)
    @rentals        = rentals.for_invoice(@working_time)

    return if @complete_sales.empty? && @rentals.empty?
    @invoice = self.invoices.build(
      working_time:      @working_time,
      total_payments:    @complete_sales.sum(:grand_total) + @rentals.sum(:grand_total),
      discounts:         @complete_sales.sum(&:calc_discount) + @rentals.sum(&:calc_discount),
      tax_total:         @complete_sales.sum(:tax_rate_total) + @rentals.sum(&:tax_rate_total),
      complete_payments: @complete_sales.where( status: 'complete' ).sum(:grand_total) + @rentals.sum(:grand_total)
    )
    generate_payments_for_invoice
    @invoice.save!
  end

  def generate_payments_for_invoice
    payments = []

    @complete_sales.each do |sale|
      sale.payments.each_with_index do |payment, index|
        payments << {payment.payment_method_id => (index + 1 == sale.payments.count) ? payment.amount - sale.change_amount : payment.amount}
      end
    end

    @rentals.each do |rental|
      rental.rental_payments.each_with_index do |payment, index|
        payments << {payment.payment_method_id => (index + 1 == rental.rental_payments.count) ? payment.amount - rental.change_amount : payment.amount}
      end
    end

    return if payments.blank?

    payments.inject{|memo, el| memo.merge( el ){|k, old_v, new_v| old_v + new_v}}.each do |pm|
      @invoice.finance_report_payments.build name: PaymentMethod.find_by_id(pm.first).name, amount: pm.last, custom_amount: pm.last
    end
  end

  def generate_credit
    @refund_sales = sales.for_credit(@working_time)
    return if @refund_sales.empty?
    @credit = self.credits.build(
      working_time:      @working_time,
      total_payments:    @refund_sales.sum(:grand_total).abs,
      complete_payments: @refund_sales.sum(:grand_total).abs,
      discounts:         0,
      tax_total:         @refund_sales.sum(:tax_rate_total).abs
    )
    generate_payments_for_credit
    @credit.save!
  end

  def generate_payments_for_credit
    Payment.where(sale_id: @refund_sales.map(&:id)).sum(:amount, group: 'payment_method_id').each do |pm|
      @credit.finance_report_payments.build name: PaymentMethod.find_by_id(pm.first).name, amount: pm.last.abs, custom_amount: pm.last.abs
    end
  end

  def smart_add_tsp_url_protocol
    return if tsp_url.blank?
    unless tsp_url[/\Ahttp:\/\//] || tsp_url[/\Ahttps:\/\//]
      self.tsp_url = "http://#{tsp_url}"
    end
  end
end
