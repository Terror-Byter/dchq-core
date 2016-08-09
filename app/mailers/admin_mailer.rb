class AdminMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def from_registraion_page options = {}
    @options = options
    mail to: 'support@divecentrehq.com', subject: 'DCHQ Support Request: Registration', from: options[:email], body: options[:message]
  end

  def from_inside_app options = {}
    @options = options
    email_with_name = %("#{options[:name]}" <#{options[:email]}>)
    mail to: 'support@divecentrehq.com', subject: "Support Request from #{options[:store]}", from: email_with_name, body: options[:message]
  end
end
