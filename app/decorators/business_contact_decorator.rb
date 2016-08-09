class BusinessContactDecorator < Draper::Decorator
  delegate_all

  def supplier_name
    model.supplier.name
  end

  def image
    h.image_tag(model.avatar.image(:large))
  end

  def tags
    model.tags.join('  ')
  end

  def no_notes?
    model.notes.empty?
  end
end
