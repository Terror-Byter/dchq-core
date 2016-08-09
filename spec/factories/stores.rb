FactoryGirl.define do
  factory :store do
    name { Faker::Company.name }
    location 'Location'
    main { true }
    currency { Currency.first || create(:currency) }
    company
    tax_rate_inclusion { true }
  end

  factory :store_tax_exclusion, parent: :store do
    tax_rate_inclusion { false }
  end
end
