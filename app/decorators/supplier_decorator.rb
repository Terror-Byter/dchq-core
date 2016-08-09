class SupplierDecorator < Draper::Decorator
  delegate_all

  def location
    model.address && model.address.country
  end

  def image
    h.image_tag(model.logo.image(:large))
  end

  def address
    model.address && model.address.full_address(:separator => ", ")
  end

  def tags
    model.tags.join('  ')
  end

  def no_business_contacts?
    model.business_contacts.empty?
  end

  def no_notes?
    model.notes.empty?
  end
end
