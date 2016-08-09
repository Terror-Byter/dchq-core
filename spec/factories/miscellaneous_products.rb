FactoryGirl.define do
  factory :miscellaneous_product do
    store { store }
    category { create(:category, store: store) }
    tax_rate { create(:tax_rate, store: store) }
    price { rand(10..100) }
  end
end
