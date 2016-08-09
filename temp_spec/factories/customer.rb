FactoryGirl.define do
  factory :customer do
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    mobile_phone { Faker::PhoneNumber.cell_phone }
    telephone { Faker::PhoneNumber.phone_number }
    company { Company.first || FactoryGirl.create(:company) }
  end
end
