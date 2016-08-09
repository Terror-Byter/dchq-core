class ServiceDecorator < Draper::Decorator
  delegate_all
  decorates_association :service_notes
  decorates_association :time_intervals, scope: :complete

  def user_full_name
    user.full_name
  end

  def customer_full_name
    customer.try(:full_name)
  end

  def customer_address
    customer.address.full_address
  end

  def customer_email
    customer.email
  end

  def customer_telephone
    customer.telephone
  end

  def customer_mobile
    customer.mobile_phone
  end

  def customer_has_email?
    !customer.email.blank?
  end

  def no_sale?
    sale.blank?
  end

  def no_service_notes?
    service_notes.empty?
  end

  def no_time_intervals?
    time_intervals.empty?
  end

  def show
    no_sale? ? model : h.edit_sale_path(model.sale)
  end

  def show_class
    status = sale.try(:status)
    if status == "complete"
      'btn btn-small btn-success btn-icon glyphicons ok_2'
    else
      'btn btn-small btn-primary btn-icon glyphicons coins'
    end
  end

  def total_price_service_items
    type_of_services_total + products.sum(&:unit_price)
  end

  def seconds_to_hours
    total_seconds = model.calculate_time_intervals
    seconds = total_seconds % 60
    minutes = (total_seconds / 60) % 60
    hours = total_seconds / (60 * 60)

    format("%02d:%02d:%02d", hours, minutes, seconds) #=> "01:00:00"
  end
end
