FactoryGirl.define do
  factory :discount do
    value { rand(100) }
    kind { "USD" }
    discountable_type { 'Sale' }
    discountable { Sale.first || FactoryGirl.create(:full_sale) }
  end
end
