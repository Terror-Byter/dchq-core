class CreditNoteDecorator < Draper::Decorator
  delegate_all

  def initial_value
    h.formatted_currency model.initial_value
  end

  def remaining
    h.formatted_currency model.remaining_value
  end

  def customer_name
    model.customer.full_name
  end
end
