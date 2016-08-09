FactoryGirl.define do
  factory :type_of_service, class: Services::TypeOfService do
    name { Faker::Name.name }
    labour { rand(1..10).to_f }
    price_of_service_kit { ["included", "additional", "include_in_service"].shuffle.first }
    labour_price { rand(10..100).to_d }
  end
end
