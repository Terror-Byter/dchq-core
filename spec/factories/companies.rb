FactoryGirl.define do
  factory :company do
    name { Faker::Company.name }
    email 'emailstore@gmail.com'
    telephone { '123456789' }
    address
    pricing_plan

    after(:build) do |company|
      company.users << create(:user, company: company)
      company.stores << create(:store, company: company)
    end
  end
end
