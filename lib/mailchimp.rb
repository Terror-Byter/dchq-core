module Mailchimp
  def sync_mailchimp record
    case record.class.name
    when "Customer" then
      fname = record.given_name
      lname = record.family_name
      phone = record.telephone.blank? ? false : record.telephone
      born_on = record.born_on.blank? ? false : record.born_on
      tags = record.tags.empty? ? false : record.tags.map{|u| u.name}.join(", ")
      mailchimp_list = "mailchimp_list_id_for_#{record.class.to_s.downcase}"
    when "Supplier" then
      fname = record.name
      lname = false
      phone = record.telephone.blank? ? false : record.telephone
      born_on = false
      tags = record.tags.empty? ? false : record.tags.map{|u| u.name}.join(", ")
      mailchimp_list = "mailchimp_list_id_for_business_contact"
    when "User" then
      fname = record.given_name
      lname = record.family_name
      phone = record.telephone.blank? ? false : record.telephone
      born_on = false
      tags = false
      mailchimp_list = "mailchimp_list_id_for_staff_member"
    end
    email = record.email

    gb = Gibbon::API.new current_user.mailchimp_api_key
    #update mailchimp record
    if gb.lists.member_info({ id: current_user.send(mailchimp_list), emails: [{ email: email }] })['data'].empty?
      gb.lists.subscribe({ id: current_user.send(mailchimp_list),
                           email: { email: email },
                           merge_vars: {
                             FNAME: fname,
                             LNAME: lname,
                             PHONE: phone,
                             BORN_ON: born_on,
                             TAGS: tags
                           },
                           double_optin: false })
    end
  end
end
