FactoryGirl.define do
  factory :certification_level_cost do
    cost { rand(10..100) }
    tax_rate
    store
    material_price { rand(10..50) }
    material_price_tax_rate { create(:tax_rate) }
    commission_rate
    certification_level
  end

  factory :certification_level_cost_fixed, parent: :certification_level_cost do
    cost { 100 }
    tax_rate { create(:tax_rate, amount: 10) }
    material_price { 50 }
    material_price_tax_rate { create(:tax_rate, amount: 15) }
  end
end
