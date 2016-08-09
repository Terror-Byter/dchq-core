FactoryGirl.define do
  factory :service_item, class: Services::ServiceItem do
    service { FactoryGirl.create(:service) }
    product { FactoryGirl.create{:product} }
  end
end
