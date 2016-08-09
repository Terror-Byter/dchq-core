class ImportMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def success user, type
    @user = user
    @type = type
    return unless user.email.present?

    mail to: user.email, bcc: 'support@divecentrehq.com', subject: I18n.t("mailers.import_mailer.success_subject")
  end

  def rejected user, type, errors
    @user = user
    @type = type
    @errors = errors
    return unless user.email.present?
    
    mail to: user.email, bcc: 'support@divecentrehq.com', subject: I18n.t("mailers.import_mailer.rejected_subject")
  end
end
