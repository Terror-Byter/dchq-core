module MailchimpActiveRecord
  extend ActiveSupport::Concern

  included do
    after_create :add_to_mailchimp
    after_destroy :delete_from_mailchimp

    private
    def add_to_mailchimp
      return if current_user_info.blank? ||
                (current_user_info.send(mailchimp_method).blank? ||
                 current_user_info.mailchimp_api_key.blank?) ||
                 self.email.blank?
      h = Gibbon::API.new current_user_info.mailchimp_api_key
      first_name = self.given_name
      last_name  = self.family_name
      h.lists.subscribe({ id: current_user_info.send(mailchimp_method),
                          email: { email: self.email },
                          merge_vars: {
                            FNAME:      first_name,
                            LNAME:      last_name,
                            DCNAME:     self.company.name,
                            WEBSITE:    self.company.website_url,
                            PHONE:      self.company.telephone,
                            SIGNUPDATE: Time.now,
                            PAID: '0'
                          },
                          double_optin: true }) rescue true
    end

    def delete_from_mailchimp
      return if current_user_info.blank? || current_user_info.send(mailchimp_method).blank?
      h = Gibbon::API.new current_user_info.mailchimp_api_key
      h.lists.unsubscribe({ id: current_user_info.send(mailchimp_method),
                            email: { email: self.email },
                            delete_member: true }) rescue true
    end

    def mailchimp_method
      "mailchimp_list_id_for_#{self.class.name.eql?("User") ? "staff_member" : self.class.name.underscore}"
    end
  end
end
