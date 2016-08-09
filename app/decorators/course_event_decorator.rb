class CourseEventDecorator < Draper::Decorator
  delegate_all
  decorates_association :event_user_participants

  def price
    h.formatted_currency(model.price.to_f - model.tax_rate_amount_line)
  end

  def edit_path
    h.edit_course_event_path(course_event_id)
  end

  def delete_path
    h.course_event_path(course_event_id)
  end

  def course_event_id
    model.parent? ? model : model.parent
  end

  def starts_at_for_form
    return h.params[:course_event][:starts_at] if h.params[:course_event] && h.params[:course_event][:starts_at]
    return nil if model.new_record?

    if all_day?
      l(model.starts_at, format: '%Y-%m-%d')
    else
      l(model.starts_at, format: '%Y-%m-%d %H:%M')
    end
  end

  def ends_at_for_form
    return h.params[:course_event][:ends_at] if h.params[:course_event] && h.params[:course_event][:ends_at]

    return nil if model.new_record?

    if all_day?
      l(model.ends_at, format: '%Y-%m-%d')
    else
      l(model.ends_at, format: '%Y-%m-%d %H:%M')
    end
  end

  def boat_color
    "##{model.boat.color}" if model.boat
  end

  def boat
    model.boat.try :name
  end

  def css_class
    "#{type_name.downcase.gsub(' ', '_')} #{'cancel-event' if model.cancel?}"
  end

  def type_name
    model.event_type.name
  end

  def name
    name = "#{model.name}#{ " - #{model.location}" unless model.location.blank? }"
    "#{ name }#{ I18n.t('decorators.course_event.full_event') if model.available_places.zero? }"
  end

  def print_event_manifest_event_path
    h.print_event_manifest_course_event_path(model)
  end

  def print_event_pickup_event_path
    h.print_event_pickup_course_event_path(model)
  end
end
