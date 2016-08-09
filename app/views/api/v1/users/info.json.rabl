object :@user

attributes :id, :email, :time_zone, :role, :created_at, :updated_at, :given_name, :family_name, :alternative_email, :telephone,
           :emergency_contact_details, :available_days, :start_date, :end_date, :contracted_hours, :mailchimp_api_key,
             :mailchimp_list_id_for_customer, :mailchimp_list_id_for_staff_member,
             :mailchimp_list_id_for_business_contact, :locale


child :company do
  attributes :id, :name
end

node(:avatar){ |user| user.decorate.avatar_url }

child :address do
  attribute :first, :second, :city, :state, :post_code
  node(:country) { |address| CountrySelect::COUNTRIES[address.country_code] unless address }
end
