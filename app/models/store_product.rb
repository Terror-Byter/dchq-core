class StoreProduct < ActiveRecord::Base
  include PgSearch

  acts_as_paranoid
  validates_as_paranoid

  pg_search_scope :search, against: [:name, :sku_code, :barcode],
                           using: {
                             tsearch: {prefix: true, any_word: true },
                             trigram: { } },
                           ignoring: :accents
  has_paper_trail

  belongs_to :store
  belongs_to :category
  belongs_to :brand
  belongs_to :supplier
  belongs_to :tax_rate, with_deleted: true
  belongs_to :commission_rate, with_deleted: true
  has_one :logo, as: :imageable, class_name: "Image", dependent: :destroy

  accepts_nested_attributes_for :logo, allow_destroy: true

  with_options presence: true do |e|
    e.validates :store
    e.validates :category
    e.validates :brand
    e.validates :supplier
    e.validates :tax_rate
    e.validates :commission_rate, if: ->(p){ p.commission_rate_money.blank? }
    e.validates :name, length: { maximum: 255 }
    e.validates :sku_code
    e.with_options numericality: { greater_than_or_equal_to: 0.0 } do |n|
      n.validates :number_in_stock, numericality: { less_than: 99999 }
    end
  end
  validates_uniqueness_of_without_deleted :sku_code, scope: :store_id

  scope :archived, ->{ where(archived: true) }
  scope :unarchived, ->{ where(archived: false) }
  scope :filter_by_supplier, ->(supplier_id){ where(supplier_id: supplier_id) }

  attr_accessible :store_id, :store, :category_id, :category, :brand_id, :brand, :supplier_id, :supplier,
                  :tax_rate_id, :tax_rate, :commission_rate_id, :commission_rate, :name, :sku_code,
                  :number_in_stock, :description, :accounting_code, :supplier_code, :supply_price, :retail_price,
                  :commission_rate_money, :markup, :barcode, :low_inventory_reminder, :sent_at, :offer_price,
                  :archived, :price_per_day, :logo_attributes

  def archived!
    update_attributes archived: true
  end

  def unarchived!
    update_attributes archived: false
  end

  def label
    "#{ name } - SKU: #{ sku_code }"
  end
end
