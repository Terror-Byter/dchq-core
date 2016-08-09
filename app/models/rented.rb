class Rented < ActiveRecord::Base
  has_paper_trail
  include Sales::Calculation

  belongs_to :rental
  belongs_to :rental_product

  with_options presence: true do |v|
    validates :rental, presence: true
    validates :rental_product, presence: true
    validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :item_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :tax_rate, presence: true
  end

  attr_accessible :rental, :rental_id, :rental_product, :rental_product_id, :quantity, :item_amount, :tax_rate

  after_save :check_rented_quantity
  after_save :update_amounts!
  after_destroy :update_amounts!

  def tax_rate_amount
    return 0 if rental.customer.zero_tax_rate?
    tax = tax_rate / 100.0
    #if tax rate inclision
    if rental.store.tax_rate_inclusion?
      without_discount = unit_price.to_f / (tax + 1) * tax
    # if tax rate exclusion
    else
      without_discount = unit_price * tax
    end
    without_discount
  end

  def tax_rate_amount_line_item
    return 0 if rental.customer.zero_tax_rate?
    tax = tax_rate / 100.0
    sum = line_item
    if rental.store.try(:tax_rate_inclusion?)
      sum.to_f * tax / (tax + 1)
    else
      sum * tax
    end
  end

  def line_item_price_with_tax_rate
    return line_item_price if rental.store.try(:tax_rate_inclusion?)
    line_item_price + tax_rate_amount_line_item
  end

  private
  def check_rented_quantity
    destroy if quantity.zero?
  end

  def update_amounts!
    rental.update_amounts!
  end
end
