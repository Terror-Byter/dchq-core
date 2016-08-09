FactoryGirl.define do
  factory :course_event, parent: :event, class: CourseEvent do
    name { Faker::Company.name }
    store
    starts_at { Time.now }
    ends_at { Time.now + 5.hours }
    event_type
    certification_level
    boat
    location { 'Super nice location' }
    additional_equipment { 'No equipment' }
    number_of_dives { rand(1..5) }
    instructions { Faker::Lorem.paragraph }
    notes { Faker::Lorem.paragraph }
    type { 'CourseEvent' }
    frequency { 'One-off' }
  end
end
