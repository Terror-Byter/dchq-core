class Brand < ActiveRecord::Base
  has_paper_trail

  belongs_to :store
  has_one :logo, as: :imageable, class_name: "Image", dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :sales, through: :products, uniq: true
  has_many :sale_products, through: :sales, uniq: true
  has_many :rental_products, dependent: :destroy

  accepts_nested_attributes_for :logo, allow_destroy: true

  validates :store, existence: true
  validates :name, presence: true

  scope :out_of_stock, scoped

  after_create :add_logo

  attr_accessible :name, :description, :logo_attributes

  def average_month_sales
    self.sales.for_the_last_month.each do |s|
      s.filter_by_id = self.id
      s.filter_by_model = :brand
    end.mean(:calc_grand_total)
  end

  def last_sale_date
    pretendent = self.sales.by_creation.last
    return I18n.t('brands.index.not_available') unless pretendent

    I18n.l(pretendent.created_at, format: :default)
  end

  private
  def add_logo
    self.create_logo if logo.blank?
  end
end
