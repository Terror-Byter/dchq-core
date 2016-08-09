class CertificationLevelCost < ActiveRecord::Base
  has_paper_trail

  belongs_to :tax_rate
  belongs_to :commission_rate
  belongs_to :certification_level
  belongs_to :store

  has_one :material_price, dependent: :destroy

  attr_accessible :store_id, :cost, :tax_rate_id, :commission_rate_id, :commission_rate_money, :material_price_attributes

  accepts_nested_attributes_for :material_price, allow_destroy: true, reject_if: ->(p){ p[:price].blank? }

  validates :store, presence: true
  with_options allow_nil: true do |v|
    v.validates :cost, numericality: { greater_than_or_equal: 0.0 }
    v.validates :certification_level, existence: { allow_nil: true }
  end
  validates :tax_rate, existence: true
  validates :commission_rate_money, presence: true, numericality: { greater_than: 0.0 }, if: ->(cl){ cl.commission_rate_id.blank? }
  validates :commission_rate, existence: true, if: ->(cl){ cl.commission_rate_money.blank? }

  scope :with_cost, ->{ where{ cost.not_eq nil } }

  def total_price_without_tax_rate
    cost.to_f + material_price.try(:price).to_f
  end
end
