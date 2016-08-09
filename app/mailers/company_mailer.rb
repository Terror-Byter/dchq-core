class CompanyMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def welcome company
    @company = company
    return unless company.email.present?

    mail to: company.email, bcc: "signups@divecentrehq.com", subject: I18n.t("mailer.company_mailer.welcome_subject")
  end

  def notify_manager current_user
    @user = current_user
    return unless @user.company.owner.email.present?

    mail to: @user.company.owner.email, subject: I18n.t("mailer.company_mailer.notify_manager_subject")
  end

  def event_cancelled_no_payments customer, event, message
    @message = message
    @event = event
    @customer = customer
    I18n.locale = @event.store.email_setting.language
    return unless @customer.email.present?

    mail(
      to: @customer.email,
      from: %("#{@event.store.name}" <#{@event.store.company.outbound_email}>),
      subject: I18n.t("mailer.company_mailer.event_cancelled_no_payments_subject",event: event.full_name )
    )
  end

  def event_participant_removed event, customer
    @event = event
    @customer = customer
    I18n.locale = @event.store.email_setting.language
    return unless @customer.email.present?

    mail(
      to: @customer.email,
      from: %("#{@event.store.name}" <#{@event.store.company.outbound_email}>),
      subject: I18n.t("mailer.company_mailer.event_participant_removed_subject", event: event.full_name)
    )
  end

  def created_new_company company
    @company = company
    mail to: 'info@divecentrehq.com', subject: 'Signup Email Address Invalid'
  end

end
