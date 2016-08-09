FactoryGirl.define do
  factory :user do
    password 'password'
    password_confirmation 'password'
    email { Faker::Internet.email }
    company
    role { 'manager' }
    current_step { 'finished' }
    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }
  end
end
