collection :@events

attributes :id, :name, :starts_at, :ends_at, :number_of_dives, :parent_id, :limit_of_registrations, :number_of_frequencies
node(:price){ |event| formatted_currency(event.price) }
node(:number_of_event_customer_participants) { |event| event.event_customer_participants.count }
node(:number_of_staff_members) { |event| event.event_user_participants.count }
node(:type) { |event| event.trip? ? 'TRIP' : event.course? ? 'COURSE' : event.event_type.try(:name) }
