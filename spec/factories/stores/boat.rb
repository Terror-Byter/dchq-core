FactoryGirl.define do
  factory :boat, class: Stores::Boat do
    store
    name { Faker::Lorem.word }
    color { '123321' }
  end
end
