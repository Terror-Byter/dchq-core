class Services::TimeIntervalDecorator < Draper::Decorator
  delegate_all

  def user_full_name
    user.full_name
  end
end
