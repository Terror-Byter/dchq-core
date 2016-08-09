FactoryGirl.define do
  factory :gift_card do
    gift_card_type { create(:gift_card_type) }
    status { GiftCard::STATUSES.keys.shuffle.first }
    solded_at { Time.now }
    available_balance { rand(100).to_d }
  end
end
