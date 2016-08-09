def service_1 sale
  store = sale.store
  customer = store.company.customers.first
  user = store.company.users.first
  FactoryGirl.create(:service, sale: sale, store: store, customer: customer, user: user, type_of_service: type_of_service_1(store))
end

def type_of_service_1 store
  FactoryGirl.create(:type_of_service, store: store, tax_rate: store.tax_rates.first)
end

FactoryGirl.define do
  factory :sale do
    grand_total { rand(100..1000) }
    change { rand(0..100) }
  end

  factory :sale_completed, parent: :sale do
    status 'complete'
  end

  factory :full_sale, parent: :sale do
    store { FactoryGirl.create(:store) }
    creator { FactoryGirl.create(:user) }
  end

  factory :sale_with_sale_products_service, parent: :full_sale do
    after(:build) do |sale|
      sale.sale_products << FactoryGirl.build(:sale_product, sale_productable_type: 'Service', sale_productable: service_1(sale))
    end
  end

  factory :completed_sale_with_sale_product_product, parent: :full_sale do
    status { 'complete' }
    after(:build) do |sale|
      sale.sale_products << FactoryGirl.build(:sale_product_product)
    end
  end

  factory :completed_sale_with_static_sale_product_product, parent: :full_sale do
    status { 'complete' }
    after(:build) do |sale|
      sale.sale_products << FactoryGirl.build(:static_sale_product_product)
    end
  end

  factory :sale_with_payment, parent: :full_sale do
    after(:build) do |sale|
      sale.payments << FactoryGirl.build(:payment)
    end
  end

  factory :sale_with_event_customer_participant, parent: :full_sale do
    after(:build) do |sale|
      sale.event_customer_participants << FactoryGirl.build(:event_customer_participant)
    end
  end
end
