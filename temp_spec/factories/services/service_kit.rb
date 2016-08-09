FactoryGirl.define do
  factory :service_kit, class: Services::ServiceKit do
    name { Faker::Company.name }
    stock_level { rand(5) }
    supply_price { rand(10..100).to_d }
    retail_price { rand(10..100).to_d }
    tax_rate { TaxRate.first || FactoryGirl.create(:tax_rate) }
    type_of_service { TypeOfService.first || FactoryGirl.create(:type_of_service) }
    store { Store.first || FactoryGirl.create(:store) }
  end
end
