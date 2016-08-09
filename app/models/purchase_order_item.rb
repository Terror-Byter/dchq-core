class PurchaseOrderItem < ActiveRecord::Base
  has_paper_trail

  belongs_to :purchase_order
  belongs_to :product, with_deleted: true

  attr_accessible :price, :quantity, :quantity_rejected

  # FIXME: due to a mysterious reason validations don't work: we are able to save negative values
  validates :price, presence: true, numericality: { greater_than_or_equal: 0 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal: 0 }
  validates :product_id, uniqueness: { scope: :purchase_order_id, message: I18n.t('errors.only_distinct_products_allowed') }

  after_save :save_purchase_order!

  def sub_total
    unit_price * quantity
  end

  def unit_price
    if price.nil?
      product.unit_price
    else
      price
    end
  end

  def quantity_accepted_range
    (0..(quantity_max_available_for_amend))
  end

  def quantity_rejected_range
    (0..(quantity_max_available_for_amend))
  end

  # For view - the sum of quantity and quanity_rejected
  # noinspection RubyInstanceMethodNamingConvention
  def quantity_max_available_for_amend
    quantity + quantity_rejected
  end

  private

  # autosave on belongs_to is fired **before** saving this record, so it's not enough for us
  def save_purchase_order!
    purchase_order.save! unless purchase_order.nil? || purchase_order.new_record?
  end
end
