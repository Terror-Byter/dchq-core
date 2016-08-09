FactoryGirl.define do
  factory :gift_card_type do
    value { rand(100).to_d }
    valid_for { GiftCardType::VALID_INTERVAL_IN_MONTH.shuffle.first }
    company { Company.first || FactoryGirl.create(:company) }
  end
end
