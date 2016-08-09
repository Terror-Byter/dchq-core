FactoryGirl.define do
  factory :address do
    first { Faker::Address.street_address }
    second ''
    city { Faker::Address.city }
    state { Faker::Address.state }
    post_code { Faker::Address.zip_code }
    country_code 'us'
  end
end
