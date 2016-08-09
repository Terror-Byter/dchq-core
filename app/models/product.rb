class Product < StoreProduct
  has_many :sale_products, conditions: { sale_productable_type: 'Product' }, dependent: :destroy, foreign_key: :sale_productable_id
  has_many :sales, through: :sale_products, uniq: true
  has_many :service_items, class_name: "Services::ServiceItem"

  with_options presence: true do |p|
    p.with_options numericality: { greater_than_or_equal_to: 0.0 } do |n|
      n.validates :low_inventory_reminder, numericality: { less_than: 99999 }
      n.validates :supply_price
      n.validates :retail_price
      n.validates :commission_rate_money, if: ->(p){ p.commission_rate_id.blank? }
    end
  end

  scope :in_stock,       ->{ where(:number_in_stock.gt => 0) }
  scope :out_of_stock,   ->{ where(number_in_stock: 0) }
  scope :need_to_remind, ->{ where{ (low_inventory_reminder.gteq number_in_stock) & (archived.eq false) & ((sent_at.lteq 7.days.ago) | (sent_at.eq nil)) } }

  class << self
    def field_names
      {
        category_id:            I18n.t("activerecord.attributes.product.category_id"),
        brand_id:               I18n.t("activerecord.attributes.product.brand_id"),
        supplier_id:            I18n.t("activerecord.attributes.product.supplier_id"),
        tax_rate_id:            I18n.t("activerecord.attributes.product.tax_rate_id"),
        commission_rate_id:     I18n.t("activerecord.attributes.product.commission_rate_id"),
        name:                   I18n.t("activerecord.attributes.product.name"),
        sku_code:               I18n.t("activerecord.attributes.product.sku_code"),
        number_in_stock:        I18n.t("activerecord.attributes.product.number_in_stock"),
        description:            I18n.t("activerecord.attributes.product.description"),
        accounting_code:        I18n.t("activerecord.attributes.product.accounting_code"),
        supplier_code:          I18n.t("activerecord.attributes.product.supplier_code"),
        supply_price:           I18n.t("activerecord.attributes.product.supply_price"),
        retail_price:           I18n.t("activerecord.attributes.product.retail_price"),
        commission_rate_money:  I18n.t("activerecord.attributes.product.commission_rate_money"),
        markup:                 I18n.t("activerecord.attributes.product.markup"),
        deleted_at:             I18n.t("activerecord.attributes.product.deleted_at"),
        barcode:                I18n.t("activerecord.attributes.product.barcode"),
        image:                  I18n.t("activerecord.attributes.product.image"),
        low_inventory_reminder: I18n.t("activerecord.attributes.product.low_inventory_reminder"),
        archived:               I18n.t('activerecord.attributes.product.archived')
      }
    end

    def units_in_stock
      sum(:number_in_stock)
    end

    def stock_value
      sum('number_in_stock * supply_price')
    end

    def field_names_barcode_export
      {
        name:         I18n.t("activerecord.attributes.product.name"),
        category_id:  I18n.t("activerecord.attributes.product.category_id"),
        sku_code:     I18n.t("activerecord.attributes.product.sku_code"),
        barcode:      I18n.t("activerecord.attributes.product.barcode"),
        retail_price: I18n.t("activerecord.attributes.product.retail_price"),
        description:  I18n.t("activerecord.attributes.product.description"),
      }
    end
  end

  def status
    number_in_stock.zero? ? I18n.t('models.product.out_of_stock') : I18n.t('models.product.in_stock')
  end

  def class_type
    self.class.name
  end

  def name_for_sale
    name
  end

  def quantity
    1
  end

  def sub_total_for_service
    retail_price
  end

  def unit_price
    offer_price || retail_price
  end

  def tax_rate_amount
    tax_rate.try(:amount).to_f
  end

  def line_item_price sale = nil
    return 0 if sale.nil?
    res = line_item(sale)
    res *= -1 if sale.refunded?
    res
  end

  def line_item sale = nil
    return unit_price * quantity if sale.blank? || sale.store.tax_rate_inclusion?
    (unit_price + tax_rate_amount) * quantity
  end

  def calc_tax_rate
    return 0 if store.tax_rate_inclusion
    (tax_rate.amount / 100) * retail_price
  end
end
