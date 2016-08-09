FactoryGirl.define do
  factory :certification_level do
    name { Faker::Company.name }
    store
    certification_agency
  end
end
