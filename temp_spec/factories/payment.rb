FactoryGirl.define do
  factory :payment do
    amount { rand(100).to_d }
    payment_transaction { Faker::Lorem.word }
    sale { Sale.first || FactoryGirl.create(:full_sale) }
    cashier { User.first || FactoryGirl.create(:user) }
    payment_method { PaymentMethod.first || FactoryGirl.create(:payment_method) }
  end
end
