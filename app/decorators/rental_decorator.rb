class RentalDecorator < Draper::Decorator
  delegate_all

  def available_statuses
    return [[I18n.t('decorators.rental.in_progress'), :in_progress]] if model.booked?
    list = [[I18n.t('decorators.rental.complete'), :complete]]
    list.unshift([I18n.t('decorators.rental.overdue'), :overdue]) if model.in_progress?
    list
  end
end

