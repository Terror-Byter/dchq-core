FactoryGirl.define do
  factory :sale_product do
    quantity { rand(1..10) }
    sale { Sale.first || FactoryGirl.create(:full_sale) }
  end

  factory :sale_product_product, parent: :sale_product do
    sale_productable_type 'Product'
    sale_productable_id { FactoryGirl.create(:product).id }
  end

  factory :static_sale_product_product, parent: :sale_product_product do
    quantity { 5 }
    sale_productable_id { FactoryGirl.create(:product, retail_price: 90).id }
  end
end
