class EventCustomerParticipantDecorator < Draper::Decorator
  delegate_all
  decorates_association :customer

  def event_name
    model.event.name
  end

  def event_cancel
    model.event.cancel?
  end

  def starts_at
    l model.event.starts_at, format: :default
  end

  def customer_name
    if model.customer
      "#{ model.customer.full_name } (#{model.customer.email})".html_safe
    else
      "#{ model.group_name } (#{ h.pluralize(model.quantity, 'people')})"
    end
  end

  def link_to_staff
    return "-" unless event_user_participant
    h.link_to event_user_participant.user.full_name, event_user_participant.user
  end

  def associated_staff_for_manifest
    return "-" unless event_user_participant
    event_user_participant.user.full_name
  end

  def fins_size
    model.customer.fins if model.customer
  end

  def bcd_size
    model.customer.bcd if model.customer
  end

  def wetsuit_size
    model.customer.wetsuit if model.customer
  end

  def available_customers
    customers.map{ |cus| [cus.full_name, cus.id] }
  end

  def spaces_available
    return h.t('decorators.event_customer_participants.unlimited') if model.event.limit_of_registrations.blank?
    model.event.available_places
  end

  def customers
    h.current_company.customers.without_walk_in
  end

  def url
    new_record? ? h.event_event_customer_participants_path(h.parent) : h.event_event_customer_participant_path(h.parent, model)
  end

  def available_users
    h.parent.event_user_participants.map{ |u| [u.user.full_name, u.id] }
  end

  def assigned_transport
    event_customer_participant_transports.map{ |t| "#{h.l(t.time, format: :only_time)} #{t.transport.name} #{t.information}" if t.transport }.compact * ', '
  end

  def certificate
    customer.primary_certificate if customer
  end

  def unit_price
    h.formatted_currency event_unit_price.abs
  end

  def tax_rate
    h.formatted_currency event_tax_rate_amount_line.abs
  end

  def price
    h.formatted_currency model.grand_total_price #model.event_line_item_with_discount.abs
  end

  def productable_name
    model.event.name
  end

  def price_for_tsp
    "^ ^#{ h.tsp_formatted_currency(model.event_unit_price) }".to_tsp.html_safe
  end

  def paypa_booking_complete public_key
    h.paypal_complete_bookings_url(public_key: public_key, event_customer_participant_id: model.id, payment_type: "paypal", only_path: false )
  end

  def cancel_booking public_key
    h.cancel_bookings_url(public_key: public_key, event_customer_participant_id: model.id, message: "Your card has expired" )
  end

  def reject_path
    !model.unpaid? && model.sale ? h.reject_paid_event_event_customer_participant_path(model.event, model) : h.reject_event_event_customer_participant_path(model.event, model)
  end

  def name
    if model.event.course?
      "#{model.event.certification_agency.try(:name)} - #{model.event.certification_level.try(:name)} #{I18n.t('dive_course')} (#{self.customer.try(:full_name)})"
    else
      "#{model.event.try(:name)} (#{self.customer.try(:full_name)})"
    end
  end
end
