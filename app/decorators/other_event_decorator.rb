class OtherEventDecorator < Draper::Decorator
  delegate_all
  decorates_association :event_user_participants

  def price
    h.formatted_currency(model.price)
  end

  def type_name
    model.event_type.name
  end

  def location
    model.location
  end

  def boat
    model.boat.try(:name)
  end

  def boat_color
    "##{model.boat.color}" if model.boat
  end

  def trip_name
    model.event_trip.try(:name)
  end

  def name
    location = model.location.blank? ? '' : " - #{model.location}"
    name = if !model[:name].blank?
             "#{model[:name]}#{location}"
           elsif model.event_type.try(:name).eql?("Dive Trip")
             "#{trip_name} (#{type_name})#{location}"
           else
             "#{type_name}#{location}"
           end
    "#{ name }#{ I18n.t('decorators.other_event.full_event') if model.available_places.zero? }"
  end

  def css_class
    "#{type_name.downcase.gsub(' ', '_')} #{'cancel-event' if model.cancel?}"
  end

  def edit_path
    h.edit_other_event_path(model)
  end

  def delete_path
    h.other_event_path(model)
  end

  def starts_at_for_form
    return h.params[:other_event][:starts_at] if h.params[:other_event] && h.params[:other_event][:starts_at]
    return nil if model.new_record?

    if all_day?
      l(model.starts_at, format: '%Y-%m-%d')
    else
      l(model.starts_at, format: '%Y-%m-%d %H:%M')
    end
  end

  def ends_at_for_form
    return h.params[:other_event][:ends_at] if h.params[:other_event] && h.params[:other_event][:ends_at]

    return nil if model.new_record?

    if all_day?
      l(model.ends_at, format: '%Y-%m-%d')
    else
      l(model.ends_at, format: '%Y-%m-%d %H:%M')
    end
  end

  def print_event_manifest_event_path
    h.print_event_manifest_other_event_path(model)
  end

  def print_event_pickup_event_path
    h.print_event_pickup_other_event_path(model)
  end
end
