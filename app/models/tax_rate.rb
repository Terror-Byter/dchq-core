class TaxRate < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail

  belongs_to :store

  has_many :service_kits, class_name: "Services::ServiceKit"
  has_many :type_of_services, class_name: "Services::TypeOfService"
  has_many :products
  has_many :miscellaneous_products
  has_many :sale_products, through: :products
  has_many :kit_hires, class_name: "ExtraEvents::KitHire"
  has_many :transports, class_name: "ExtraEvents::Transport"
  has_many :insurances, class_name: "ExtraEvents::Insurance"
  has_many :additionals, class_name: "ExtraEvents::Additional"
  has_many :rental_products
  has_many :renteds, through: :rental_products

  attr_accessible :amount, :identifier

  validates :store_id, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, uniqueness: { scope: :store_id }
  validates :identifier, length: { maximum: 255 }, allow_blank: true

  before_destroy :check_that_tax_has_no_products

  def default?
    store && store.tax_rates.first.eql?(self)
  end

  def withdrawal_coef
    1 - amount / 100.0
  end

  def formatted_amount
    "#{amount}%"
  end

  private
  def check_that_tax_has_no_products
    errors.add(:base, I18n.t("models.tax_rate.cannot_remove_tax_rate")) unless products.blank?
  end
end
