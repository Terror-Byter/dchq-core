FactoryGirl.define do
  factory :event_customer_participant do
    price { rand(500).to_d }
    sale { Sale.first || FactoryGirl.create(:full_sale) }
    event_user_participant { EventUserParticipant.first || FactoryGirl.create(:event_user_participant) }
    customer { Customer.first || FactoryGirl.create(:customer) }
    event { OtherEvent.first || FactoryGirl.create(:other_event) }
  end
end
