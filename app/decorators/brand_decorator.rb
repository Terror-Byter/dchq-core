class BrandDecorator < Draper::Decorator
  delegate_all
  decorates_association :sales, scope: :newest_first
  decorates_association :products

  def products_count
    model.products.count
  end

  def products_in_stock
    model.products.units_in_stock
  end

  def products_stock_value
    model.products.stock_value
  end

  def logo
    h.image_tag(model.logo.image(:large))
  end

  def no_sales?
    model.sales.empty?
  end

  def no_products?
    model.products.empty?
  end
end
