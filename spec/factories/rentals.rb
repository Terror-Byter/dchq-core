# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rental do
    user
    customer
    store
    pickup_date { Date.today }
    return_date { Date.today + 1.days }
  end

  factory :empty_rental, parent: :rental do
  end
end
