class SaleProduct < ActiveRecord::Base
  include Sales::Calculation
  has_paper_trail

  QUANTITY_LIMIT = 999
  EVENTS_TYPES = ['MaterialPrice', 'EventCustomerParticipantOptions::KitHire',
                  'EventCustomerParticipantOptions::Insurance', 'EventCustomerParticipantOptions::Transport',
                  'EventCustomerParticipantOptions::Additional']

  belongs_to :sale, include: [:discount]#, inverse_of: :sale_products
  belongs_to :sale_productable, polymorphic: true, with_deleted: true
  belongs_to :product, foreign_key: :sale_productable_id, class_name: "Product"
  belongs_to :miscellaneous_product, foreign_key: :sale_productable_id, class_name: "MiscellaneousProduct"
  belongs_to :event_customer_participant, foreign_key: :sale_productable_id, class_name: 'EventCustomerParticipant'

  has_many :refunded_sale_products, class_name: "SaleProduct", foreign_key: "original_id"

  validates :sale, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :by_brand,                   ->(id){ joins(:product).where(product: { brand_id: id }) }
  scope :by_category,                ->(id){ joins(:product).where(product: { category_id: id }) }
  scope :by_all,                     ->(id){ scoped }
  scope :by_sp_id,                   ->(sp_id){ where(id: sp_id) }
  scope :gift_cards,                 ->{ where(sale_productable_type: "GiftCard") }
  scope :not_service_type,           ->{ where{ sale_productable_type.not_eq 'Service' } }
  scope :only_services,              ->{ where(sale_productable_type: "Service") }
  scope :only_products,              ->{ where(sale_productable_type: "Product") }
  scope :misc_products_and_products, ->{ where(sale_productable_type: %w[Product MiscellaneousProduct]) }

  after_create :update_sale_amounts!
  after_update :update_sale_amounts!
  after_destroy :update_sale_amounts!

  after_create :update_number_in_stock_on_create!, if: ->{ sale_productable.class_type.eql?("Product") }
  after_update :update_number_in_stock_on_update!, if: ->{ %w[Product MiscellaneousProduct].include?(sale_productable.class.name) }
  after_destroy :update_number_in_stock_on_destroy!, if: ->{ sale_productable.class_type.eql?("Product") }
  after_save :update_gift_card_status_on_save, if: ->{ sale_productable.class_type.eql?("GiftCard") }
  after_destroy :change_status_for_services, if: ->{ sale_productable.class_type.eql?("Service") }

  attr_accessible :sale_productable_type, :sale_productable_id, :quantity, :original_id,
                  :price, :tax_rate, :commission_rate

  def quantities_options
    (0..[self.sale_productable.number_in_stock + self.quantity, QUANTITY_LIMIT].min).to_a
  end

  def refund_quantity_limit
    self.quantity - self.refunded_sale_products.sum(:quantity)
  end

  def event?
    EVENTS_TYPES.include? sale_productable_type
  end

  def can_be_refunded?
    return false if event?

    refund_quantity_limit > 0
  end

  def attrs_for_clone(refund_quantity)
    { sale_productable_id: sale_productable_id, quantity: refund_quantity || refund_quantity_limit, original_id: id, sale_productable_type: sale_productable_type }
  end

  def clone_discount(original)
    build_prod_discount(original.prod_discount.attrs_for_clone) if original.prod_discount
  end

  #TODO need to refactoring
  def tax_rate_amount
    return 0 if sale.customers.first.try(:zero_tax_rate?)
    tax = if sale_productable_type == 'Product' && sale.complete? && !tax_rate.nil?
            tax_rate
          elsif sale_productable.class.base_class == EventCustomerParticipantOptions::EventCustomerParticipantOption
            sale_productable.send(:method).tax_rate.amount
          else
            sale_productable.tax_rate_amount
          end

    tax /= 100

    if sale.store.tax_rate_inclusion?
      unit_price.to_f / (tax + 1) * tax
    else
      unit_price * tax
    end.abs
  end

  def tax_rate_amount_line_item
    # return 0 if sale.customers.first.try(:zero_tax_rate?)
    tax = if sale_productable_type == 'Product' && sale.complete? && !tax_rate.nil?
            tax_rate
          else
            sale_productable.try(:tax_rate_amount).to_f
          end

    tax /= 100
    sum = unit_price * quantity - line_item_discount

    if sale.store.try(:tax_rate_inclusion?)
      sum.to_f * tax / (tax + 1)
    else
      sum * tax
    end.abs
  end

  def name
    sale_productable.try(:name)
  end

  #TODO Need to remake calcs for freezed commission_rate
  def calc_comission_rate
    p = sale_productable
    return 0 if p.commission_rate_money.to_f.zero? && p.commission_rate.try(:amount).to_f.zero?
    line_item_price
  end

  def calc_comission_earned
    p = sale_productable
    return 0 if p.commission_rate_money.to_f.zero? && p.commission_rate.try(:amount).to_f.zero?
    return p.commission_rate_money * quantity if !p.commission_rate_money.to_f.zero?
    line_item_price * p.commission_rate.amount / 100.0
  end

  def smart_line_item_price
    self[:smart_line_item_price].to_f
  end

  private
  def update_sale_amounts!
    sale.reload.apply_default_discount_for_products
    sale.reload.update_amounts!
  end

  def update_number_in_stock_on_create!
    update_number_in_stock!(quantity * (sale.refunded? ? 1 : -1))
  end

  def update_number_in_stock_on_update!
    update_number_in_stock!(quantity_was - quantity) if sale_productable.class.name.eql?('Product')
    destroy if quantity.zero?
  end

  def update_number_in_stock_on_destroy!
    update_number_in_stock!(quantity * (sale.refunded? ? -1 : 1))
  end

  def update_number_in_stock!(offset)
    sale_productable.update_attributes(number_in_stock: sale_productable.number_in_stock + offset)
  end

  def update_gift_card_status_on_save
    destroy and sale_productable.destroy if quantity.zero?
  end

  def change_status_for_services
    sale_productable.update_attributes(status: "in_progress", sale_id: nil)
  end
end
