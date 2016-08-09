class Category < ActiveRecord::Base
  has_paper_trail

  belongs_to :store
  has_many :products, dependent: :destroy, include: [:brand, :supplier]
  has_many :miscellaneous_products, dependent: :destroy
  has_many :sales, through: :products, uniq: true, include: [:discount]
  has_many :sale_products, through: :sales, uniq: true
  has_many :rental_products, dependent: :destroy

  validates :store, existence: true
  validates :name, presence: true

  attr_accessible :name, :description

  scope :out_of_stock, scoped

  #TODO: memcache needed
  def average_month_sales
    self.sales.for_the_last_month.each do |s|
      s.filter_by_id = self.id
      s.filter_by_model = :category
    end.mean(:calc_grand_total)
  end

  def last_sale_date
    pretendent = self.sales.by_creation.last
    return I18n.t('brands.index.not_available') unless pretendent

    I18n.l(pretendent.created_at, format: :default)
  end

  def all_product_ids
    products.pluck(:id) + miscellaneous_products.pluck(:id)
  end
end
