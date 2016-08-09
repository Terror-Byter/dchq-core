#noinspection RubyClassVariableUsageInspection
class PurchaseOrder < ActiveRecord::Base
  extend Enumerize
  has_paper_trail

  STATUSES = {
    pending: I18n.t('enumerize.purchase_order.status.pending'),
    sent_to_supplier: I18n.t('enumerize.purchase_order.status.sent_to_supplier'),
    expecting_delivery: I18n.t('enumerize.purchase_order.status.expecting_delivery'),
    received_in_part: I18n.t('enumerize.purchase_order.status.received_in_part'),
    received_in_full: I18n.t('enumerize.purchase_order.status.received_in_full'),
    received_in_part_amended: I18n.t('enumerize.purchase_order.status.received_in_part_amended'),
  }

  @@statuses_initialized = false

  RECEIVED_STATUSES = [:received_in_part, :received_in_full, :received_in_part_amended]
  DEFAULT_STATUS = :pending

  after_initialize :init
  before_save :update_grand_total

  belongs_to :supplier
  belongs_to :delivery_location, class_name: 'Store', foreign_key: 'delivery_location_id'
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'

  has_many :purchase_order_items, dependent: :destroy
  accepts_nested_attributes_for :purchase_order_items, allow_destroy: true

  scope :newest_first, order('created_at DESC')
  scope :pending, where(status: :pending.to_s)
  scope :sent_to_supplier, where(status: :sent_to_supplier.to_s)
  scope :expecting_delivery, where(status: :expecting_delivery.to_s)
  scope :received_in_part, where(status: :received_in_part.to_s)
  scope :received_in_full, where(status: :received_in_full.to_s)
  scope :received, where('status = ? OR status = ? OR status = ?',
                         :received_in_part.to_s,
                         :received_in_full.to_s,
                         :received_in_part_amended.to_s)
  scope :of_user, ->(user_id){ where(creator_id: user_id) }

  #TODO: validate expected_delivery set only when status is :expecting_delivery
  attr_accessible :expected_delivery, :purchase_order_items_attributes
  enumerize :status, in: STATUSES.keys

  validates :status, inclusion: { in: STATUSES.keys.map(&:to_s) }
  validates_datetime :expected_delivery, allow_blank: true

  def self.total_items_count(status)
    status = DEFAULT_STATUS if status.nil?
    PurchaseOrderItem.joins(:purchase_order).where(purchase_order: {status: status.to_s}).count
  end

  def self.find_all_of_company(dc_id)
    self.joins(:delivery_location).where('stores.company_id = ?', dc_id).select('purchase_orders.*')
  end

  def self.create(creator, company, supplier_id, delivery_location_id)
    @purchase_order = PurchaseOrder.new
    @purchase_order.creator = creator

    # TODO: query supplier and delivery_location via Company methods (to be defined yet) calling them on current_company
    supplier = Supplier.
        joins(:company).
        where(company_id: company.id).
        # NOTE: we have to select 'deleted_at' to avoid bug condition in acts_as_paranoid,
        # see https://github.com/goncalossilva/acts_as_paranoid/issues/75
        select([:id, :deleted_at]).
        find_by_id(supplier_id)
    Rails.logger.warn t('models.purchase_order.warnings.no_supplier_provided') if supplier.nil?

    delivery_location = Store.
        joins(:company).
        where(company_id: company.id).
        select(:id).
        find_by_id(delivery_location_id)
    if delivery_location.nil?
      delivery_location = current_company.stores.first # choosing first as default
      Rails.logger.warn t('models.purchase_order.warnings.no_delivery_location_provided')
    end

    @purchase_order.supplier = supplier
    @purchase_order.delivery_location = delivery_location
    @purchase_order.save
    @purchase_order
  end

  def add_product store, product_id, quantity
    product = store.products.where(id: product_id).first
    if product.supplier_id != supplier.id
      @purchase_order_item = PurchaseOrderItem.new
      @purchase_order_item.errors.add('supplier', t('models.purchase_order.errors.add_product.wrong_supplier'))
    else
      @purchase_order_item = PurchaseOrderItem.new
      @purchase_order_item.product = product
      @purchase_order_item.price = product.supply_price
      # FIXME: this validation should be in model, but it doesn't work there
      @purchase_order_item.quantity = if quantity.to_i <= 0 then 1 else quantity end
      @purchase_order_item.purchase_order = self
      @purchase_order_item.save
    end
    @purchase_order_item
  end

  def select_allowed_products products
    # TODO: should recreate this rejection algorithm by means of SQL somehow
    po_product_ids = get_related_product_ids # products that have already been added to this PO, to exclude them
    # returning only products that haven't been attached to items of this order
    products.reject { |p| po_product_ids.include? p.id }
  end

  def assign_supplier(supplier_id)
    self.supplier_id = supplier_id
    save
  end

  def remove_supplier
    self.supplier_id = nil
    save
  end

  def empty
    purchase_order_items.clear
    save # to update totals
  end

  def add_note note_text
    self.note = note_text
    save
  end

  def send_email_to_supplier email, store, status = nil
    if supplier.email != email
      supplier.email = email
      unless supplier.save
        errors.add('supplier', I18n.t('models.purchase_order.errors.send_email_to_supplier.has_malformed_email'))
        false
      end
    end

    begin
      PurchaseOrderMailer.supplier_email(self, store).deliver
    rescue StandardError => e
      Rails.logger.error e.message + "\n " + Rails.backtrace_cleaner.clean(e.backtrace).join("\n ")
      return false
    end
    self.status = status || :sent_to_supplier

    # TODO: hack, passing status to this method should be removed in future
    success = mark_received_on_current_status! false # don't raise error on wrong status
    success = save unless success # not in any of the 'received' states
    success
  end

  def set_expected_delivery expected_delivery
    self.expected_delivery = expected_delivery unless expected_delivery.blank?
    self.status = :expecting_delivery
    save
  end

  def update_grand_total
    self.grand_total = calc_grand_total
  end

  def pending?
    status.pending?
  end

  # TODO: make it a status somehow
  def received?
    status.received_in_part? || status.received_in_full? || status.received_in_part_amended?
  end

  # TODO: make it a status somehow
  def received_in_part?
    status.received_in_part? || status.received_in_part_amended?
  end

  # TODO: make it a status somehow
  def sent?
    status.sent_to_supplier? || status.expecting_delivery?
  end

  # TODO: make it a status somehow
  def editable?
    status.pending? || status.received_in_part?
  end

  # TODO: make it a status somehow
  def amendable?
    status.received_in_part?
  end

  # Order is in it's final
  # TODO: make it a status somehow
  def fixed?
    status.received_in_full? || status.received_in_part_amended?
  end

  #noinspection RubyInstanceMethodNamingConvention
  def mark_received_on_current_status!(raise = true)
    case status.to_sym
      when :received_in_part
        mark_received_in_part!
      when :received_in_part_amended
        mark_fixed! false
      when :received_in_full
        mark_fixed! true
      else
        if raise
          raise StandardError, "Wrong current status #{status} for order, must be in [#{RECEIVED_STATUSES.join(', ')}]"
        else
          false
        end
    end
  end

  def mark_fixed!(full = true)
    self.reload
    if fixed?
      raise StandardError, "This #{self.class.name} has been already marked as received has a fixed state!"
    end

    self.status = full ? :received_in_full : :received_in_part_amended
    self.fixed_total = update_grand_total # calculate and assign
    success = true

    self.purchase_order_items.each do |item|
      item.product.number_in_stock += item.quantity
      success &&= item.product.save
    end

    save && success
  end

  def mark_received_in_part!
    self.fixed_total = update_grand_total # calculate and assign
    self.status = :received_in_part
    save
  end

  private

  def calc_grand_total
    purchase_order_items.map(&:sub_total).sum
  end

  def init
    unless @@statuses_initialized
      @@statuses_initialized = true

      STATUSES[:pending] = I18n.t('enumerize.purchase_order.status.pending')
      STATUSES[:sent_to_supplier] = I18n.t('enumerize.purchase_order.status.sent_to_supplier')
      STATUSES[:expecting_delivery] = I18n.t('enumerize.purchase_order.status.expecting_delivery')
      STATUSES[:received_in_part] = I18n.t('enumerize.purchase_order.status.received_in_part')
      STATUSES[:received_in_full] = I18n.t('enumerize.purchase_order.status.received_in_full')
      STATUSES[:received_in_part_amended] = I18n.t('enumerize.purchase_order.status.received_in_part_amended')
    end
    self.status ||= DEFAULT_STATUS if self.has_attribute? :status # protecting in case of select() queries
  end

  def get_related_product_ids
    PurchaseOrder.
        joins(:purchase_order_items).
        where(id: self.id).
        pluck('purchase_order_items.product_id') # map to the array of ids
  end
end