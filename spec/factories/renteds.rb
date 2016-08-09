# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rented do
    rental_product
    rental
    quantity { 1 }
    item_amount { 100 }
    tax_rate { 10 }
  end
end
