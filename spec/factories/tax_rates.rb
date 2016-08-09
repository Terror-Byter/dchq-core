FactoryGirl.define do
  factory :tax_rate do
    amount { rand(10..99) }
    store
  end
end
