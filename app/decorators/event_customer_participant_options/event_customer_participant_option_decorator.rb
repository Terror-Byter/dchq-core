class EventCustomerParticipantOptions::EventCustomerParticipantOptionDecorator < Draper::Decorator
  delegate_all

  def price_for_tsp
    "^ ^#{ h.tsp_formatted_currency(model.unit_price) }".to_tsp.html_safe
  end
end
