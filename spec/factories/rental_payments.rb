# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rental_payment do
    rental
    payment_method
    amount { rand(10..99) }
  end
end
