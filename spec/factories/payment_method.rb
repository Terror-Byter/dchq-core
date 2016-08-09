FactoryGirl.define do
  factory :payment_method do
    name { ["Paypal", "Credit Card"].shuffle.first }
    store
    xero_code { Faker::Lorem.word }
  end
end
