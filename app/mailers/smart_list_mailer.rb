class SmartListMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def send_email(company, receipts, subject, body)
    @receipts = receipts
    @subject = subject
    @body    = body

    return unless receipts.present?

    mail to: receipts, from: %("#{company.name}"" <#{company.outbound_email}>), subject: subject

  end
end
