object :@event

attributes :id, :name, :location, :starts_at, :ends_at, :limit_of_registrations, :number_of_dives, :additional_equipment, :notes

node(:price){ |event| formatted_currency(event.price) }

child(:boat) { attributes :id, :name }

child(:event_user_participants) do
  attributes :role, :id
  node(:full_name) { |event_user_participant| event_user_participant.user.full_name }
  node(:avatar) { |event_user_participant| event_user_participant.user.avatar.image.url }
  node(:event_customer_participants) do |eup|
    eup.event_customer_participants.for_event(@event.id).map{ |ecp| { customer_id: ecp.customer_id, full_name: ecp.customer.full_name } }
  end
end

node(:event_customer_participants) do
  @event.event_customer_participants.map do |ecp|
    { id:        ecp.id,
      full_name: ecp.customer.full_name,
      bcd:       "#{ecp.customer.bcd} (#{customer_equipment_to_human ecp.customer.bcd_own})",
      fins:      "#{ecp.customer.fins} (#{customer_equipment_to_human ecp.customer.fins_own})",
      wetsuit:   "#{ecp.customer.wetsuit} (#{customer_equipment_to_human ecp.customer.wetsuit_own})"}
  end
end
