FactoryGirl.define do
  factory :customer do
    company
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
    sequence(:email) { |n| "email+#{ n }@gmail.com"}
    gender { 'male' }
    send_event_related_emails { true }
    telephone { Faker::PhoneNumber.phone_number }
    mobile_phone { Faker::PhoneNumber.phone_number }
    source { Faker::Lorem.word }
    default_discount_level { rand(99) }
    tax_id { rand(50) }
    zero_tax_rate { false }
    tag_list { 'Tag' }
    emergency_contact_details { Faker::Lorem.word }
    hotel_name { Faker::Lorem.word }
    room_number { '2c' }
    customer_experience_level_id { nil }
    fins { 'M' }
    bcd { 'XL' }
    wetsuit { 'XL' }
    weight { rand(100) }

    after(:build) do |c|
      c.build_address first: Faker::Address.street_address,
                      second: '',
                      city: Faker::Address.city,
                      state: Faker::Address.state,
                      country_code: 'US',
                      post_code: '1234'
      c.custom_fields.build name: Faker::Lorem.word, value: Faker::Lorem.word
    end

  end
end
