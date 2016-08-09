class SaleMailer < ActionMailer::Base
  helper :application

  default from: Devise.mailer_sender

  def send_receipt sale, recepient, file
    return if sale.store.email_setting.disable_sales_receipt_email?
    @sale = sale
    @recepient = recepient
    attachments['receipt.pdf'] = { mime_type: 'application/pdf', content: file[:pdf_file] }
    Time.zone = sale.store.time_zone
    I18n.locale = sale.store.email_setting.language
    return unless recepient.present?

    mail(
      to: recepient,
      from: %("#{@sale.store.name}" <#{sale.company.outbound_email}>),
      subject: I18n.t('mailers.sale_mailer.send_receipt_subject', id: @sale.receipt_id)
    )
  end

  def send_rental_receipt rental, recepient, file
    return if rental.store.email_setting.disable_rental_receipt_email?

    @rental = rental
    @recepient = recepient
    attachments['receipt.pdf'] = { mime_type: 'application/pdf',
      content: file }
    Time.zone = rental.store.time_zone
    I18n.locale = rental.store.email_setting.language
    return unless recepient.present?

    mail(
      to: recepient,
      from: %("#{@rental.store.name}" <#{rental.store.company.outbound_email}>),
      subject: I18n.t('mailers.sale_mailer.send_rental_receipt_subject', id: @rental.id)
    )
  end

  def booking_confirmed_online_for_customer sale
    return if sale.store.email_setting.disable_booking_confirmed_email?
    @sale = sale
    @event_customer_participant = @sale.event_customer_participants.first
    @recepient = @event_customer_participant.customer.email
    attachments['event.ics'] = generate_ics(@event_customer_participant).export()
    Time.zone = sale.store.time_zone
    I18n.locale = sale.store.email_setting.language
    return unless @recepient.present?

    mail(
      to: @recepient,
      from: %("#{@sale.store.name}" <#{sale.store.company.outbound_email}>),
      subject: "CONFIRMED: Event Booking for #{@event_customer_participant.event.full_name}"
    )
  end

  def booking_online_for_shop sale, ecp
    @sale = sale
    @event_customer_participant = ecp
    @recepient = @sale.store.company.email
    Time.zone = sale.store.time_zone
    I18n.locale = sale.store.email_setting.language
    return unless @recepient.present?

    mail(
      to: @recepient,
      from: "Dive Centre HQ <#{sale.store.company.outbound_email}>",
      subject: "New Event Booking for #{@event_customer_participant.event.full_name}"
    )
  end

  def send_bookings_email_for_customer sale, ecp
    return if sale.store.email_setting.disable_online_event_booking_email?

    @sale = sale
    @event_customer_participant = ecp
    @recepient = @event_customer_participant.customer.email
    Time.zone = sale.store.time_zone
    I18n.locale = sale.store.email_setting.language
    return unless @recepient.present?

    mail(
      to: @recepient,
      from: %("#{@sale.store.name}" <#{sale.store.company.outbound_email}>),
      subject: "Event Booking Receipt: #{@event_customer_participant.event.full_name}"
    )
  end

  def send_update_ecp_email ecp, email
    @ecp = ecp
    mail(
      to: email,
      from: %("#{ecp.event.store.name}" <#{ecp.event.store.company.outbound_email}>),
      subject: "Event Booked: #{@ecp.event.full_name}"
    )
  end

  def send_bookings_not_paid_email_for_customer event_customer_participant
    @event_customer_participant = event_customer_participant
    @recepient = @event_customer_participant.customer.email
    @store = @event_customer_participant.event.store
    Time.zone = @store.time_zone
    I18n.locale = @store.email_setting.language

    return if @store.email_setting.disable_booking_confirmed_email?
    return unless @recepient.present?

    mail(
      to: @recepient,
      from: %("#{@store.name}" <#{@store.company.outbound_email}>),
      subject: "Event Booking: #{@event_customer_participant.event.full_name}"
    )
  end

  def send_bookings_not_paid_email_for_store event_customer_participant
    @event_customer_participant = event_customer_participant
    @store = @event_customer_participant.event.store
    @recepient = @store.company.email
    Time.zone = @store.time_zone
    I18n.locale = @store.email_setting.language

    return if @store.email_setting.disable_booking_confirmed_email?
    return unless @recepient.present?

    mail(
      to: @recepient,
      from: "Dive Centre HQ <#{@store.company.outbound_email}>",
      subject: "New Event Booking for #{@event_customer_participant.event.full_name}"
    )
  end

  def send_bookings_not_paid_email_for_customer_approved event_customer_participant
    @event_customer_participant = event_customer_participant
    @store = @event_customer_participant.event.store
    @recepient = @event_customer_participant.customer.email
    Time.zone = @store.time_zone
    I18n.locale = @store.email_setting.language

    return if @store.email_setting.disable_booking_confirmed_email?
    return unless @recepient.present?

    mail(
      to: @recepient,
      from: %("#{@store.name}" <#{@store.company.outbound_email}>),
      subject: "CONFIRMED: #{@event_customer_participant.event.full_name}"
    )
  end

  def email_event_confirmed_1daybefore_for_customer event_customer_participant
    @event_customer_participant = event_customer_participant
    @store = @event_customer_participant.event.store
    Time.zone = @store.time_zone
    I18n.locale = @store.email_setting.language

    return if @store.email_setting.disable_event_reminder_email?

    @recepient = @event_customer_participant.customer.email
    return unless @recepient.present?

    mail(
      to: @recepient,
      from: %("#{@store.name}" <#{@store.company.outbound_email}>),
      subject: "REMINDER: Confirmed Event Booking for #{@event_customer_participant.event.name} on #{@event_customer_participant.event.starts_at.in_time_zone(@store.time_zone).strftime("#{@event_customer_participant.event.starts_at.day.ordinalize} %B, %Y at %I:%M%P")}"
    )
  end

  def send_bookings_email_for_customer_reject event_customer_participant, reason
    @event_customer_participant = event_customer_participant
    @store = @event_customer_participant.event.store
    @recepient = @event_customer_participant.customer.email
    @reason = reason
    Time.zone = @store.time_zone
    I18n.locale = @store.email_setting.language
    return unless @recepient.present?

    mail(
      to: @recepient,
      from: %("#{@store.name}" <#{@store.company.outbound_email}>),
      subject: "REJECTED: Event Booking #{@event_customer_participant.event.full_name}"
    )
  end

  private

  def generate_ics event_customer_participant
    event = RiCal.Event do
      description "#{event_customer_participant.event.name}, at #{event_customer_participant.event.store.name} (#{event_customer_participant.event.store.company.telephone})"
      dtstart event_customer_participant.event.starts_at
      dtend event_customer_participant.event.ends_at
      location event_customer_participant.event.location
      add_attendee event_customer_participant.event_user_participant.user.email
    end
    event
  end
end
