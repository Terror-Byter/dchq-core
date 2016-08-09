FactoryGirl.define do
  factory :category do
    name { Faker::Company.name }
    description { Faker::Lorem.paragraph }
    store
  end
end
