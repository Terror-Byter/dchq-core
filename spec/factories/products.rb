FactoryGirl.define do
  factory :product do
    name { Faker::Company.name }
    sku_code { Faker::Number.number(10) }
    description { Faker::Lorem.paragraph }
    number_in_stock { Faker::Number.number(2) }
    low_inventory_reminder 3
    brand
    category
    supplier
    accounting_code { Faker::Code.isbn }
    supplier_code { Faker::Code.isbn }
    barcode { Faker::Number.number(10) }
    supply_price { 105 }
    markup { 20 }
    retail_price { 126 }
    tax_rate
    commission_rate
    store
    archived false

    after(:build) do |p|
      p.build_logo
    end
  end
end
