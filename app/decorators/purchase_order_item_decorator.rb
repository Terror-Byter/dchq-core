class PurchaseOrderItemDecorator < Draper::Decorator
  delegate_all

  def image
    h.image_tag(model.product.logo.image(:thumb), size: "30x30") if has_logo?
  end

  def has_logo?
    model.product.logo.present?
  end

  def product
    model.product.name
  end

  def price
    h.amount_with_precision(model.price)
  end

  def price_formatted
    h.formatted_currency(model.price)
  end

  def sub_total
    h.formatted_currency(model.sub_total)
  end

  def sku
    model.product.sku_code
  end

  def supplier_code
    model.product.supplier_code
  end

  def quantity_accepted_options
    model.quantity_accepted_range.to_a
  end

  def quantity_rejected_options
    model.quantity_rejected_range.to_a
  end

  def name_with_sku
    "#{model.product.name} (##{model.product.sku_code})"
  end
end
