class EventUserParticipantDecorator < Draper::Decorator
  delegate_all

  def url
    new_record? ? h.collection_path : h.event_event_user_participant_path(h.parent, model)
  end

  def full_name
    user.full_name
  end

  def assigned_customers
    event_customer_participants.map{ |cus| h.link_to cus.customer.full_name, cus.customer }.join(', ')
  end
end
