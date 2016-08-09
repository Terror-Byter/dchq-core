collection :@users

attributes :id, :email, :given_name, :family_name, :alternative_email, :telephone, :emergency_contact_details

child :address do
  attribute :first, :second, :city, :state, :post_code
  node(:country) { |address| CountrySelect::COUNTRIES[address.country_code] unless address }
end
