class EventDecorator < Draper::Decorator
  delegate_all

  def boat_color
    "##{model.boat.color}" if model.boat
  end

  def type_name
    model.event_type.name
  end

  def css_class
    "#{type_name.downcase.gsub(' ', '_')} #{'cancel-event' if model.cancel?}"
  end

  def boat
    model.boat.try(:name)
  end

  def edit_path
    h.event_path(model)
  end
end
