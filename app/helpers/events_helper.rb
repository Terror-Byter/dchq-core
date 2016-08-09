module EventsHelper
  def cancel_confirmation_link event
    if event.no_registrations?
      cancel_confirmation_no_registrations_event_path(event)
    else
      cancel_confirmation_with_registrations_event_path(event)
    end
  end

  def calculate_event_time events
    time_array = events.map{|u| u.ends_at - u.starts_at}
    time_array.inject{|sum, el| sum + el}.to_f
  end

  def convert_seconds_to_hours_and_mins seconds
    total_hours = (seconds / 1.hours).to_i
    total_minutes = ((seconds - total_hours.hours.seconds) / 1.minutes).to_i
    "#{total_hours}#{":#{total_minutes}" unless total_minutes.zero?}"
  end
end
