class ServiceMailer < ActionMailer::Base
  helper :application

  def note_added note
    @service = note.notable
    @note = note
    I18n.locale = @service.store.email_setting.language
    return unless @service.customer.email.present?

    mail(
      to:       @service.customer.email,
      from:     %("#{@service.store.name}" <#{@service.store.company.outbound_email}>),
      subject:  I18n.t("mailer.service_mailer.note_added_subject", kit: @service.kit, serial: @service.serial_number)
    )
  end

  def servicing_collection service, sale
    return if sale.store.email_setting.disable_service_ready_for_collection_email?
    @service = service
    @sale = sale
    I18n.locale = sale.store.email_setting.language
    return unless @service.customer.email.present?

    mail(
      to: @service.customer.email,
      from: %("#{@sale.store.name}" <#{@service.store.company.outbound_email}>),
      subject:  I18n.t("mailer.service_mailer.service_collection_subject")
    )
  end
end
