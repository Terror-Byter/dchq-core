class StoreProductDecorator < Draper::Decorator
  delegate_all
  decorates_association :sales, scope: :newest_first

  def brand_name
    model.brand.name
  end

  def category_name
    model.category.name
  end

  def supplier_name
    model.supplier.name
  end

  def image
    h.image_tag(model.logo.image(:original))
  end

  def no_commission_rate?
    model.commission_rate.blank?
  end

  def commission_rate
    model.commission_rate.formatted_amount
  end

  def tax_rate
    model.tax_rate.formatted_amount
  end
end
