class Services::ServiceKitDecorator < Draper::Decorator

  delegate_all

  def price
    h.formatted_currency(model.line_item_price)
  end
end
