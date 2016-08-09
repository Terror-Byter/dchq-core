FactoryGirl.define do
  factory :service do
    serial_number { Faker::Lorem.word }
    booked_in { Date.today.beginning_of_month }
    collection_date { Date.today }
    #status { Service::STATUSES.keys.shuffle.first }
    status 'booked'
    kit { Faker::Lorem.words }
    terms_and_conditions "1"
    barcode { Faker::Lorem.word }
    type_of_service { FactoryGirl.create(:type_of_service) }
    sale { FactoryGirl.create(:full_sale) }
    store { Store.first || FactoryGirl.create(:store) }
  end
end
