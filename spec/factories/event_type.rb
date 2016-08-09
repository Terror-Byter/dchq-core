FactoryGirl.define do
  factory :event_type do
    name { ["Dive Trip", "Meeting", "Other", "Social"].shuffle.first }
  end
end
