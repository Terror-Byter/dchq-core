class Sale < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  require 'stripe'

  attr_accessible :grand_total, :change, :note

  STATUSES = {"active" => "Active",
              "layby" => "Lay-by",
              "complete_layby" => "Lay-by",
              "complete" => "Complete",
              "layby_refund" => "Layby Refund",
              "refund" => "Refund",
              "complete_refund" => "Refund"}

  OUTSTANDING_STATUSES = %w(active layby refund)
  REFUND_STATUSES = %w(refund complete_refund)
  COMPLETE_STATUSES = %w(complete complete_layby layby_refund complete_refund)
  REPORT_STATUSES = %w(complete)
  FILTER_MODELS = [:brand, :category]
  AVAILABLE_LIMIT = 9999

  belongs_to :store
  belongs_to :creator, class_name: "User"
  belongs_to :parent, class_name: "Sale", foreign_key: 'parent_id'
  has_many :children, class_name: "Sale", foreign_key: 'parent_id'
  has_one :company, through: :store

  has_one :discount, as: :discountable
  has_many :sale_products#, inverse_of: :sale
  has_many :sale_customers
  has_many :payments
  has_many :credit_notes

  has_many :customers, through: :sale_customers, unscoped: true#, inverse_of: :sales
  has_many :products, through: :sale_products, uniq: true, source_type: 'Product', source: :sale_productable
  has_many :event_customer_participants, through: :sale_products
  has_many :events, through: :event_customer_participants

  with_options allow_destroy: true do |ad|
    ad.accepts_nested_attributes_for :discount
    ad.accepts_nested_attributes_for :sale_products
    ad.accepts_nested_attributes_for :payments, reject_if: ->(p){ p["amount"].blank? || p['amount'].to_f.zero? }
  end
  accepts_nested_attributes_for :event_customer_participants

  with_options existence: true do |e|
    e.validates :store
    e.validates :creator
  end
  with_options presence: true do |p|
    p.validates :status, inclusion: { in: STATUSES.keys }
    p.validates :grand_total, numericality: true
    p.validates :change, numericality: true
  end
  validates :receipt_id, uniqueness: { scope: :store_id }, allow_blank: true

  attr_accessible :creator, :sale_products_attributes, :event_customer_participants_attributes, :status,
                  :payments_attributes, :store_id, :creator_id, :booking, :parent_id, :discount_attributes,
                  :tax_rate_total, :cost_of_goods, :taxable_revenue, :receipt_id, :course_events_total_price,
                  :other_events_total_price, :completed_at

  attr_accessor :filter_by_model, :filter_by_id, :after_save_passed

  scope :newest_first,                         ->{ order('created_at DESC') }
  scope :by_creation,                          ->{ order(:created_at) }
  scope :for_the_last_month,                   ->{ where(:created_at.gt => 1.month.ago) }
  scope :for_the_last_month_and_begin_of_week, ->{ where(:created_at.gt => 1.month.ago.beginning_of_week) }
  scope :outstanding,                          ->{ where(status: OUTSTANDING_STATUSES) }
  scope :not_layby,                            ->{ where{ status.not_eq 'layby' } }
  scope :not_refunded,                         ->{ where(:status.not_in => REFUND_STATUSES) }
  scope :for_this_period,                      ->(start_date){ where(created_at: start_date..Date.today) }
  scope :for_store,                            ->(store_id){ where(store_id: store_id) }

  # Quick Filter Scopes
  scope :created_this_week,                    ->{ where(:created_at.gt => Time.now.beginning_of_week) }
  scope :refunded,                             ->{ where(status: REFUND_STATUSES) }
  scope :layby,                                ->{ where(status: "layby") }
  scope :completed,                            ->{ where(status: COMPLETE_STATUSES) }
  scope :refund_complete,                      ->{ where(status: 'complete_refund') }
  scope :for_credit,                           ->(working_time){ refund_complete.where(completed_at: working_time.open_at..working_time.close_at) }
  scope :for_date,                             ->(date){ where(created_at: date.beginning_of_day..date.end_of_day) }
  scope :for_invoice,                          ->(working_time){ where(status: COMPLETE_STATUSES, completed_at: working_time.open_at..working_time.close_at) }
  scope :active, where(status: 'active')
  scope :empty, ->{ active.includes(:sale_products).where( sale_products: { sale_id: nil } ) }
  scope :completed_for_current_month, ->{ completed.where( created_at: Time.now.beginning_of_month..Time.now) }
  scope :completed_for_all_time, where(status: 'complete')
  scope :sales_without_refunded_childs_per_month, ->{ completed_for_current_month.includes(:children).where{ (children.status.not_in REFUND_STATUSES) | (children.id.eq nil)} }
  scope :sales_without_refunded_childs_all_time, ->{ completed_for_all_time.includes(:children).where{ (children.status.not_in REFUND_STATUSES) | (children.id.eq nil)} }
  scope :for_report, ->{ where(status: REPORT_STATUSES) }

  scope :sales_without_refunded_childs_for_last_week, ->{ completed.where(created_at: 1.week.ago.beginning_of_week..1.week.ago.end_of_week).includes(:children).where{ (children.status.not_in Sale::REFUND_STATUSES) | (children.id.eq nil)} }

  after_create :create_receipt_id
  after_save :update_amounts!, :update_status_for_service

  def self.available_limit_exceeded?
    self.count >= AVAILABLE_LIMIT
  end

  def update_amounts!(force = false, ecps = nil)
    #self.reload.apply_default_discount(ecps) if !ecps.nil? && self.event_customer_participants.include?(ecps)
    #self.reload.apply_tariff_discount
    if store && ( !@after_save_passed || force )
      @after_save_passed = true
      if parent && parent.status == 'layby_refund'
        sum = parent.payments.sum(:amount)
      else
        sum = calc_grand_total
        tax = calc_tax_rate_total
        if customers.first.try(:zero_tax_rate?)
          if store.tax_rate_inclusion?
            sum -= tax
          else
            tax = 0
          end
        else
          sum += tax unless store.tax_rate_inclusion?
        end
      end

      update_attributes! grand_total: sum,
                         change: change_amount,
                         tax_rate_total: tax,
                         course_events_total_price: calc_event_grand_total('CourseEvent'),
                         other_events_total_price: calc_event_grand_total('OtherEvent')
    end
  end

  def update_status!
    unless status_changed? || refund?
      status = payments.empty? ? "active" : "layby"
      update_attributes(status: status)
    end
  end

  STATUSES.keys.each do |status|
    define_method "#{status}?" do
      self.status.eql?(status)
    end
  end

  def filter_by_model
    FILTER_MODELS.include?(@filter_by_model) ? @filter_by_model : :all
  end

  def human_status
    STATUSES[self.status]
  end

  def sub_total
    calc_grand_total
  end

  def services_full_tax_rate_amount
    sale_products.only_services.map{ |sp| sp.sale_productable.full_tax_rate_amount }.sum
  end

  def calc_grand_total
    sale_products.not_service_type.map(&:line_item_price).sum + services_grand_total
  end

  def services_grand_total
    sale_products.only_services.map{ |sp| sp.sale_productable.grand_total }.sum
  end

  def calc_discount
    sale_products.sum(&:line_item_discount)
  end

  def payment_tendered
    self.payments.tendered
  end

  def change_amount
    all_payments = payment_tendered.values.sum
    all_payments *= -1 if all_payments > 0 && (refund? || complete_refund?)
    all_payments - grand_total
  end

  def empty!
    [:sale_products, :payments].each{ |res| self.send(res).destroy_all }
    self.discount.try(:destroy)
    self.update_amounts!
    self.update_status!
  end

  def can_contain_discount?
    self.sale_products.joins(:prod_discount).empty?
  end

  def paid?
    self.refund? ? self.change_amount <= 0 : self.change_amount >= 0
  end

  def can_be_completed?
    (self.layby? || self.refund? || self.grand_total.zero?) && self.paid? && self.has_some_items?
  end

  def can_be_outstanding?
    self.layby? && self.has_some_items? && !self.paid?
  end

  def has_some_items?
    (self.sale_products.count + self.event_customer_participants.count) > 0
  end

  def outstanding?
    OUTSTANDING_STATUSES.include?(self.status)
  end

  def refunded?
    REFUND_STATUSES.include?(self.status)
  end

  def completed?
    COMPLETE_STATUSES.include?(self.status)
  end

  def refund_quantity_limit
    self.sale_products.map(&:refund_quantity_limit).sum
  end

  def can_be_refunded?
    !self.refunded? && (self.refund_quantity_limit + self.event_customer_participants.not_refunded.count) > 0
  end

  def receipt_id
    self[:receipt_id].blank? ? self.id : self[:receipt_id]
  end

  def to_pay
    completed? || status == 'complete_refund' ? 0 : grand_total - payment_tendered.values.sum
  end

  def add_events!(options)
    ecps = if options[:ecp_id]
             sale_customers.first_or_create(customer_id: options[:customer_id])
             EventCustomerParticipant.where(id: options[:ecp_id])
           elsif options[:customer_id]
             Customer.find(options[:customer_id].to_i).event_customer_participants
           end

    ecps.each do |ecp|
      sale_products.create sale_productable_type: 'EventCustomerParticipant',
                            sale_productable_id: ecp.id,
                            quantity: ecp.dynamic_quantity

      if ecp.event.course?
        if material_price = ecp.event.store.certification_level_costs.find_by_certification_level_id(ecp.event.certification_level_id).try(:material_price)
          sale_products.create sale_productable_type: 'MaterialPrice',
                               sale_productable_id: material_price.id,
                               quantity: ecp.dynamic_quantity
        end
      end

      sale_products.create sale_productable_type: 'EventCustomerParticipantOptions::KitHire',
                           sale_productable_id:    ecp.event_customer_participant_kit_hire.id,
                           quantity: ecp.dynamic_quantity if ecp.event_customer_participant_kit_hire && !ecp.event_customer_participant_kit_hire.unit_price.zero?

      sale_products.create sale_productable_type: 'EventCustomerParticipantOptions::Insurance',
                           sale_productable_id:   ecp.event_customer_participant_insurance.id,
                           quantity: ecp.dynamic_quantity  if ecp.event_customer_participant_insurance && !ecp.event_customer_participant_insurance.unit_price.zero?

      ecp.event_customer_participant_transports.each do |ecp_t|
        next if ecp_t.quantity.zero? || ecp_t.unit_price.zero?
        sale_products.create sale_productable_type: ecp_t.class.name,
                             sale_productable_id: ecp_t.id,
                             quantity: ecp_t.dynamic_quantity * ecp.dynamic_quantity
      end

      ecp.event_customer_participant_additionals.each do |ecp_a|
        next if ecp_a.quantity.zero? || ecp_a.unit_price.zero?
        sale_products.create sale_productable_type: ecp_a.class.name,
                             sale_productable_id: ecp_a.id,
                             quantity: ecp_a.dynamic_quantity * ecp.dynamic_quantity
      end
    end
  end

  def self.create_empty(creator, store, customer_id = nil)
    current_company = creator.company
    customer_id = current_company.customers.map(&:id).include?(customer_id.to_i) ? customer_id : current_company.default_customer.id

    sale = store.sales.create(creator: creator)
    sale.sale_customers.create(customer_id: customer_id)
    sale
  end

  def refund!(options = {})
    raise "Exception" unless self.can_be_refunded?

    refunded_sale = Sale.create!(attrs_for_clone)
    refunded_sale.update_attributes booking: self.booking, parent_id: self.id

    self.discount && refunded_sale.build_discount(self.discount.attrs_for_clone)

    sale_products = SaleProduct.where(id: options[:sale_product_id])

    sale_products.each_with_index do |sp, index|
      if sp.sale_productable_type == 'EventCustomerParticipant'
        ecp = sp.sale_productable

        refunded_sale.sale_products.build sale_productable_type: 'EventCustomerParticipant',
          sale_productable_id: ecp.id,
          quantity: 1

        if ecp.event.course?
          if material_price = ecp.event.store.certification_level_costs.find_by_certification_level_id(ecp.event.certification_level_id).try(:material_price)
            refunded_sale.sale_products.build sale_productable_type: 'MaterialPrice',
              sale_productable_id: material_price.id,
              quantity: 1
          end
        end

        refunded_sale.sale_products.build sale_productable_type: 'EventCustomerParticipantOptions::KitHire',
          sale_productable_id:    ecp.event_customer_participant_kit_hire.id,
          quantity: 1 if ecp.event_customer_participant_kit_hire && !ecp.event_customer_participant_kit_hire.unit_price.zero?

        refunded_sale.sale_products.build sale_productable_type: 'EventCustomerParticipantOptions::Insurance',
          sale_productable_id:  ecp.event_customer_participant_insurance.id,
          quantity: 1  if ecp.event_customer_participant_insurance && !ecp.event_customer_participant_insurance.unit_price.zero?

        ecp.event_customer_participant_transports.each do |ecp_t|
          next if ecp_t.quantity.zero? || ecp_t.unit_price.zero?
          refunded_sale.sale_products.build sale_productable_type: ecp_t.class.name,
            sale_productable_id: ecp_t.id,
            quantity: ecp_t.dynamic_quantity
        end

        ecp.event_customer_participant_additionals.each do |ecp_a|
          next if ecp_a.quantity.zero? || ecp_a.unit_price.zero?
          refunded_sale.sale_products.build sale_productable_type: ecp_a.class.name,
            sale_productable_id: ecp_a.id,
            quantity: ecp_a.dynamic_quantity
        end
      else
        refunded_sale.refund_sale_product(options[:refund_quantity][index], sp)
      end
    end

    refunded_sale.customers << customers

    refunded_sale.save!
    update_attributes! status: 'layby_refund' if layby?

    refunded_sale.update_amounts! true

    refunded_sale
  end

  def refund_sale_product(refund_quantity, original)
    self.sale_products.build(original.attrs_for_clone(refund_quantity)).clone_discount(original)
  end

  def send_bookings_emails
    SaleMailer.delay.booking_confirmed_online_for_customer(self)
  end

  def refund_charge
    #if Stripe
    if !parent.payments.first.payment_transaction.blank? && parent.payments.first.payment_method.name.eql?("Credit Card") && self.store.company.set_stripe?
      self.stripe_refund
    elsif !parent.payments.first.payment_transaction.blank? && parent.payments.first.payment_method.name.eql?("Paypal") && store.company.set_paypal?
      self.paypal_refund
    end
  end


  def stripe_refund
    Stripe.api_key = store.company.payment_credential.stripe_secret_key
    ch = Stripe::Charge.retrieve(parent.payments.first.payment_transaction)
    ch.refund


    Stripe.api_key = Figaro.env.stripe_api_key

    ch["refunded"] and ch["paid"]
  end

  def paypal_refund
    paypal_options = { login: store.company.payment_credential.paypal_login,
                       password: store.company.payment_credential.paypal_password,
                       signature: store.company.payment_credential.paypal_signature,
                       allow_guest_checkout: true }

    gateway = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)

    response = gateway.refund nil, self.parent.payments.first.payment_transaction#, { subject: "You've Received A Refund", note: "Refund for #{event_customer_participants.first.event.name} on #{event_customer_participants.first.event.starts_at.strftime("%dth %B, %Y at %I:%M%P")}" }
    errors.add(:base, response.message) unless response.success?
    response.success?
  end

  def update_gift_cards_status
    sale_products.find_all{|i| i[:sale_productable_type] == "GiftCard"}.each do |sale_product|
      sale_product.sale_productable.update_attributes(status: "un-used", solded_at: Time.now)
    end
  end

  def find_gift_cards
    sale_products.find_all{|i| i[:sale_productable_type] == "GiftCard"}.map{|i| i.sale_productable}
  end

  def has_only_walkin?
    customers.count.eql?(1) and customers.first.full_name == "Walk In"
  end

  def name
    "##{receipt_id} #{refunded? ? "[#{ I18n.t('models.sale.refunded') }]" : ""}"
  end


  def apply_tariff_discount
    event_trips = event_customer_participants.map{|u| u.event.trip? ? u : nil}.compact

    return if store.try(:event_tariffs).blank? or event_trips.blank? # return if die shop has not event tariffs or sale has no event trips

    event_tariff = store.event_tariffs.where{(min.lteq event_trips.count) & (max.gteq event_trips.count)}.try(:first)

    return if event_tariff.blank? #return if store has event tariff for our event trips numbers

    event_trips.map{|u| u.event_customer_participant_discount.update_attributes(value: nil) if u.event_customer_participant_discount}

    event_trips.each do |et|
      et.create_event_customer_participant_discount(kind: 'percent', value: event_tariff.percentage)
    end
  end

  def apply_default_discount ecps = nil
    return if ecps.customer.default_discount_level.blank? or !ecps.event_customer_participant_discount.blank?
    discount = ecps.build_event_customer_participant_discount(kind: 'percent', value: ecps.customer.default_discount_level)
    discount.save
  end

  def apply_default_discount_for_products
    discount = customers.map{|a| a.default_discount_level}.compact.try(:max)
    return if discount.blank? or discount.zero?
    self.sale_products.only_products.each do |sale_product|
      next unless sale_product.prod_discount.blank?
      sale_product.reload.create_prod_discount(kind: 'percent', value: discount)
    end
  end

  def sale_discount
    return 0 unless discount
    return discount.value unless discount.percent?
    sale_products.map(&:apply_overlall_discount).sum + event_customer_participants.map(&:apply_overlall_discount).sum
  end

  def line_items_has_discount
    sale_products.each do |sp|
      return true if sp.prod_discount && sp.prod_discount.value > 0
    end
    event_customer_participants.each do |ecp|
      return true if ecp.event_customer_participant_discount && ecp.event_customer_participant_discount.value > 0
    end
    false
  end

  def has_discount
    discount && discount.value > 0
  end

  def freeze_product_prices
    sale_products.misc_products_and_products.each do |sp|
      SaleProduct.where(id: sp.id).update_all(price: sp.unit_price, tax_rate: sp.sale_productable.tax_rate.try(:amount), commission_rate: sp.sale_productable.class.name.eql?("MiscellaneousProduct")  ?  nil : sp.sale_productable.try(:commission_rate).try(:amount))
    end
  end

  def calc_cost_of_goods
    sale_products.select{|sp| sp.sale_productable_type == 'Product'}.
      map{ |p| p.sale_productable.try(:supply_price) * p.quantity  }.sum
  end

  def invoice_status
    {
      'layby' => 'SUBMITTED',
      'complete_layby' => 'SUBMITTED',
      'complete' => 'AUTHORISED',
      'complete_refund' => 'AUTHORISED'
    }[status] || 'SUBMITTED'
  end

  def invoice_type
    return 'ACCPAY' if refunded?

    'ACCREC'
  end

  def invoice_number
    return "BILL-#{created_at.strftime("%Y-%m-%d")}-#{id}" if refunded?

    "SALE-#{created_at.strftime("%Y-%m-%d")}-#{id}"
  end

  def invoice_line_amount_types
    store.tax_rate_inclusion? ? 'Inclusive' : 'Exclusive'
  end

  def invoice_attributes
    {
      type: invoice_type,
      contact: {
        # id: store.xero.contact_remote_id,
        name: customers.first.full_name
      },
      date: created_at,
      due_date: created_at,
      invoice_number: invoice_number,
      status: invoice_status,
      line_items: generate_line_items,
      line_amount_types: invoice_line_amount_types
    }
  end

  def generate_payments
    payments.inject([]) do |payments, payment|
      payments << {
        invoice: {
          invoice_id: xero_invoice_id
        },
        account: {
          code: payment.payment_method.xero_code
        },
        date: payment.created_at.to_date,
        amount: payment.amount
      }
      payments
    end
  end

  def generate_line_items
    sale_products.inject([]) do |array, sp|

      name = sp.name
      unit_price = sp.unit_price
      tax_amount = sp.tax_rate_amount_line_item

      if customers.first.try(:zero_tax_rate?)
        name << ' (tax exempt)'
        unit_price -= tax_amount
        tax_amount = 0
      end

      array << {
        description: name,
        quantity: sp.quantity,
        unit_amount: unit_price || 0,
        account_code: store.xero.default_sale_account,
        tax_amount: tax_amount
      }

      array.last[:discount_rate] = ((1 - (sp.line_item/unit_price)) * 100) unless refunded?

      if sp.sale_productable.kind_of?(Service)
        complimentary_service = sp.sale_productable.complimentary_service

        sp.sale_productable.kits.each do |kit|
          array << {
            description: kit.type_of_service.name_for_sale,
            quantity: kit.type_of_service.quantity,
            unit_amount: complimentary_service ? 0 : kit.type_of_service.unit_price,
            account_code: store.xero.default_sale_account
          }
          array << {
            description: kit.type_of_service.service_kit.name,
            quantity: kit.type_of_service.service_kit.quantity,
            unit_amount: complimentary_service ? 0 : kit.type_of_service.service_kit.unit_price,
            account_code: store.xero.default_sale_account
            } if kit.type_of_service.service_kit
        end

        sp.sale_productable.products.each do |product|
          array << {
            description: product.name,
            quantity: product.quantity,
            unit_amount: complimentary_service ? 0 : product.unit_price,
            account_code: store.xero.default_sale_account
          }
        end
      end
      array
    end
  end

  def send_xero
    return unless store.xero.individual?
    return unless COMPLETE_STATUSES.include?(status)

    Delayed::Job.enqueue(DelayedJob::Xero::SendSale.new(id))
  end

  def send_scubatribe
    return unless store.scubatribe_connected?
    return unless sale_products.any? { |sp| sp.sale_productable_type == 'EventCustomerParticipant' }

    Delayed::Job.enqueue(DelayedJob::ScubaTribe::SendRequest.new(id))
  end

  private

  def calc_taxable_revenue
    sum = 0
    sale_products.not_service_type.each do |sp_product|
      sum += sp_product.line_item_price if sp_product.sale_productable.try(:tax_rate_amount).to_f > 0
    end

    sale_products.only_services.each do |sp_service|
      sp_service = sp_service.sale_productable
      sp_service.kits.each do |kit|
        sum += kit.type_of_service.line_item_price if kit.type_of_service.try(:tax_rate).try(:amount).to_f > 0
        sum += kit.type_of_service.service_kit.try(:line_item_price) if kit.type_of_service.try(:service_kit).try(:tax_rate).try(:amount).to_f > 0
      end
      sp_service.products.each do |product|
        sum += product.line_item_price if product.tax_rate_amount > 0
      end
    end
    sum
  end

  def calc_tax_rate_total
    res = sale_products.not_service_type.sum(&:tax_rate_amount_line_item) +
      services_full_tax_rate_amount
    res *= -1 if refunded?
    res
  end

  def attrs_for_clone
    res = { status: 'refund' }
    res.merge! self.attributes.symbolize_keys.slice(:store_id, :creator_id)
    res
  end

  def update_status_for_service
    return unless completed?
    sale_products.only_services.each do |sp|
      sp.sale_productable.to_complete! unless sp.sale_productable.complete?
    end
  end

  def create_receipt_id
    return if store.initial_receipt_number.blank?

    self[:receipt_id] = store.initial_receipt_number
    loop do
      save and break if valid?
      self[:receipt_id] = self[:receipt_id].next
    end
  end

  def calc_event_grand_total event_type
    ecps = event_customer_participants.joins(:event).where( event: { type: event_type } )# unless filter_by_id

    sp = []
    ecps.each do |ecp|
      sp += sale_products.where(sale_productable_type: 'EventCustomerParticipant', sale_productable_id: ecp.id)

      if ecp.event.course?
        if material_price = ecp.event.store.certification_level_costs.find_by_certification_level_id(ecp.event.certification_level_id).try(:material_price)
          sp += sale_products.where( sale_productable_type: 'MaterialPrice', sale_productable_id: material_price.id)
        end
      end

      if ecp.event_customer_participant_kit_hire
        sp += sale_products.where(sale_productable_type: 'EventCustomerParticipantOptions::KitHire', sale_productable_id: ecp.id)
      end

      if ecp.event_customer_participant_insurance
        sp += sale_products.where(sale_productable_type: 'EventCustomerParticipantOptions::Insurance', sale_productable_id: ecp.id)
      end

      ecp.event_customer_participant_transports.each do |ecp_t|
        sp += sale_products.where(sale_productable_type: 'EventCustomerParticipantOptions::Transport', sale_productable_id: ecp_t.id)
      end

      ecp.event_customer_participant_additionals.each do |ecp_a|
        sp += sale_products.where(sale_productable_type: 'EventCustomerParticipantOptions::Additional', sale_productable_id: ecp_a.id)
      end
    end

    sum = sp.sum(&:line_item_price)
    unless store.tax_rate_inclusion?
      sum += sp.sum(&:tax_rate_amount_line_item)
    end

    sum
  end
end
