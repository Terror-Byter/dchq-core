FactoryGirl.define do
  factory :pricing_plan do
    name 'Manta'
    price { rand(100) }
    number_of_users 10
    number_of_customers 100
    number_of_shops 5
    billing_period 30
    visible true
  end
end
