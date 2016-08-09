class MiscellaneousProduct < ActiveRecord::Base
  has_paper_trail

  belongs_to :store
  belongs_to :category
  belongs_to :tax_rate, with_deleted: true
  has_one :sale_product, as: :sale_productable, dependent: :destroy
  has_one :sale, through: :sale_product

  attr_accessible :price, :tax_rate_id, :store_id, :category_id, :description

  with_options presence: true do |e|
    e.validates :store
    e.validates :category
    e.validates :tax_rate
    e.validates :price, numericality: { greater_than: 0 }
  end
  validates :description, length: { maximum: 65536 }

  def unit_price
    price
  end

  def class_type
    self.class.name
  end

  def logo
    nil
  end

  def name
    I18n.t('models.miscellaneous_product.name')
  end

  def tax_rate_amount
    tax_rate.amount
  end

  def sku_code
    ''
  end
end
