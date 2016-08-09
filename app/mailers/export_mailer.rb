class ExportMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def success data, filename, type, user
    @user = user
    @type = type
    attachments[filename] = { data: data }
    return unless user.email.present?
    
    mail to: user.email, subject: I18n.t('mailers.export_mailer.success_subject')
  end
end
