FactoryGirl.define do
  factory :other_event do
    name { Faker::Company.name }
    starts_at { Date.today }
    ends_at { Date.today + 1.day }
    additional_equipment { Faker::Lorem.words }
    frequency "One-off"
    location { Faker::Address.street_address }
    event_type
    certification_level
    event_trip
    store
  end
end
