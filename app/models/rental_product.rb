class RentalProduct < StoreProduct
  has_many :renteds, dependent: :destroy
  has_many :rentals, through: :renteds, uniq: true

  validates :price_per_day, presence: true, numericality: { greater_than: 0 }

  def number_of_available
    number_in_stock - renteds.joins(:rental).where(rental_product_id: self, rental_id: rentals.in_rent).sum(:quantity)
  end

  class << self
    def currently_in_rent store
      Rented.joins(:rental).where(rental_id: store.rentals.in_rent).uniq.sum(:quantity)
    end

    def available_rental_inventory store
      store.rental_products.sum(:number_in_stock) - self.currently_in_rent(store)
    end

    def field_names
      {
        category_id:            I18n.t("activerecord.attributes.rental_product.category_id"),
        brand_id:               I18n.t("activerecord.attributes.rental_product.brand_id"),
        supplier_id:            I18n.t("activerecord.attributes.rental_product.supplier_id"),
        tax_rate_id:            I18n.t("activerecord.attributes.rental_product.tax_rate_id"),
        commission_rate_id:     I18n.t("activerecord.attributes.rental_product.commission_rate_id"),
        name:                   I18n.t("activerecord.attributes.rental_product.name"),
        sku_code:               I18n.t("activerecord.attributes.rental_product.sku_code"),
        number_in_stock:        I18n.t("activerecord.attributes.rental_product.number_in_stock"),
        description:            I18n.t("activerecord.attributes.rental_product.description"),
        accounting_code:        I18n.t("activerecord.attributes.rental_product.accounting_code"),
        supplier_code:          I18n.t("activerecord.attributes.rental_product.supplier_code"),
        supply_price:           I18n.t("activerecord.attributes.rental_product.supply_price"),
        price_per_day:          I18n.t("activerecord.attributes.rental_product.price_per_day"),
        commission_rate_money:  I18n.t("activerecord.attributes.rental_product.commission_rate_money"),
        markup:                 I18n.t("activerecord.attributes.rental_product.markup"),
        deleted_at:             I18n.t("activerecord.attributes.rental_product.deleted_at"),
        barcode:                I18n.t("activerecord.attributes.rental_product.barcode"),
        image:                  I18n.t("activerecord.attributes.rental_product.image"),
        low_inventory_reminder: I18n.t("activerecord.attributes.rental_product.low_inventory_reminder"),
        archived:               I18n.t("activerecord.attributes.rental_product.archived")
      }
    end
  end
end
