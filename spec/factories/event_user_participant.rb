FactoryGirl.define do
  factory :event_user_participant do
    role { Faker::Lorem.word }
    user { User.first || FactoryGirl.create(:user) }
    #event { Event.first || FactoryGirl.create(:event) }
    event { OtherEvent.first || FactoryGirl.create(:other_event) }
  end
end
