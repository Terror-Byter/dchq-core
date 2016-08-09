# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rental_product do
    name { Faker::Company.name }
    sku_code { Faker::Number.number(10) }
    description { Faker::Lorem.paragraph }
    number_in_stock { Faker::Number.number(2) }
    brand
    category
    supplier
    accounting_code { Faker::Code.isbn }
    supplier_code { Faker::Code.isbn }
    barcode { Faker::Number.number(10) }
    price_per_day { 126 }
    tax_rate
    commission_rate
    store
    archived false

    after(:build) do |p|
      p.build_logo
    end
  end
end
