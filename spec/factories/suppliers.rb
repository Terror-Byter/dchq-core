FactoryGirl.define do
  factory :supplier do
    name { Faker::Company.name }
    company
  end
end
