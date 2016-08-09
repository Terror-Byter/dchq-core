class EventCustomerParticipantOptions::TransportDecorator < Draper::Decorator
  delegate_all

  def price_for_tsp
    "^ ^#{ h.tsp_formatted_currency(model.unit_price * model.quantity) }".to_tsp.html_safe
  end
end
