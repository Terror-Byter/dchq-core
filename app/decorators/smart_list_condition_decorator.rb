class SmartListConditionDecorator < Draper::Decorator
  delegate_all

  def init_text
    return if model.new_record?
    case model.resource
    when 'product_purchased', 'product_not_purchased', nil then h.current_store.products
    when 'rental_completed' then h.current_store.rental_products
    when 'event_completed', 'event_not_completed' then h.current_store.events
    when 'servicing_completed' then h.current_store.type_of_services
    end.find_by_id(model.value).try(:label)
  end
end
