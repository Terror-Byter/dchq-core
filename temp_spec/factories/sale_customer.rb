FactoryGirl.define do
  factory :sale_customer do
    sale { Sale.first || FactoryGirl.create(:full_sale) }
    customer { Cusotmer.first || FactoryGirl.create(:customer) }
  end
end
