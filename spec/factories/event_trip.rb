FactoryGirl.define do
  factory :event_trip do
    name { Faker::Company.name }
    cost { 100 }
    store
    tax_rate
    commission_rate
  end
end
