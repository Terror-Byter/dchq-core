FactoryGirl.define do
  factory :commission_rate do
    amount { rand(90) }
    store
  end
end
