class MaterialPrice < ActiveRecord::Base
  has_paper_trail

  belongs_to :tax_rate, with_deleted: true
  belongs_to :certification_level_cost

  attr_accessible :price, :tax_rate_id, :certification_level_cost_id

  validates :tax_rate, presence: true
  validates :certification_level_cost, presence: true, on: :update
  validates :price, numericality: { greater_than_or_equal: 0.0 }

  def tax_rate_amount
    tax_rate.amount
  end

  def unit_price
    price_with_taxes
  end

  def line_item_price_with_discount
    price_with_taxes
  end

  def class_type
    self.class.name
  end

  def logo
    nil
  end

  def name
    I18n.t('models.material_price.material_price')
  end

  def sku_code
    nil
  end

  def number_in_stock
    1
  end

  def price_with_taxes
    material_tax = tax_rate.amount.to_f / 100
    if certification_level_cost.store.tax_rate_inclusion?
      price + price.to_f / (tax_rate.amount.to_f / 100 + 1) * material_tax
    else
      price + price.to_f * material_tax
    end
  end
end
