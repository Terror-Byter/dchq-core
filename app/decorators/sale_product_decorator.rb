class SaleProductDecorator < Draper::Decorator
  delegate_all

  def image_for_event_type
    h.image_tag(model.sale_productable.logo, size: "30x30") if service_type?
  end

  def image
    h.image_tag(model.sale_productable.logo.image(:thumb)) if has_logo? and !service_type?
  end

  def service_type?
    model.sale_productable.kind_of?(Service)
  end

  def has_logo?
    !model.sale_productable.logo.blank?
  end

  def productable_name
    model.sale_productable.name
  end

  def productable_category_name
    model.sale_productable.category.name
  end

  def productable_sku_code
    model.sale_productable.sku_code
  end

  def productable_description
    return model.sale_productable.description unless model.sale_productable.description.blank?
    model.sale_productable.name
  end

  def gift_card_type?
    model.sale_productable.kind_of?(GiftCard)
  end

  def unit_price
    h.formatted_currency model.unit_price
  end

  def tax_rate
    h.formatted_currency model.tax_rate_amount
  end

  def price
    h.formatted_currency(line_item)
  end

  def name_for_tsp
    if model.sale_productable.class.name.eql?('MiscellaneousProduct')
      "CATEGORY: #{ productable_category_name } ^ ^ #{ h.tsp_formatted_currency(model.line_item_price) }".to_tsp.html_safe
    else
      "SKU: #{ model.sale_productable.sku_code } ^ ^ #{ h.tsp_formatted_currency(model.line_item_price) }".to_tsp.html_safe
    end
  end
end
