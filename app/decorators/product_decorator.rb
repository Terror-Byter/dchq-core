class ProductDecorator < StoreProductDecorator
  def no_sales?
    model.sales.empty?
  end

  def price
    h.formatted_currency(model.line_item_price)
  end
end
