class CategoryDecorator < Draper::Decorator
  delegate_all
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

  def no_products?
    model.products.empty?
  end
end
