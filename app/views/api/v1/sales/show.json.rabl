object :@sale

attributes :id

node(:sub_total) { |sale| sale.sub_total.abs }
node(:tax_rate) { |sale| sale.tax_rate_total.abs }
node(:discount) { |sale| sale.discount }
node(:grand_total) { |sale| sale.grand_total.abs }
node(:change) { |sale| sale.change_amount.abs }
node(:payment_tendered){ |sale| sale.payments.sum(&:amount) }

child(:sale_customers) do
  attributes :id
  child(:customer) do
    attributes :id, :full_name
  end
end

node(:sale_products) do
  array = []
  @sale.sale_products.map do |sp|
    array << { id: sp.id, name: sp.sale_productable.name, unit_price: sp.unit_price, quantity: sp.quantity, total: sp.line_item_price.abs, discount: sp.try(:prod_discount) }
    if sp.sale_productable.kind_of? Service
      tos = sp.sale_productable.type_of_service
      array << { id: tos.id, name: tos.name_for_sale, unit_price: tos.unit_price, quantity: tos.quantity, total: tos.line_item_price(@sale).abs  }

      if tos.service_kit
        array << { id: tos.service_kit.id, name: tos.service_kit.name_for_sale, unit_price: tos.service_kit.unit_price, quantity: tos.service_kit.quantity, total: tos.service_kit.line_item_price(@sale).abs }
      end
      sp.sale_productable.products.map do |pr|
        array << { id: sp.id, name: pr.name_for_sale, unit_price: pr.unit_price, quantity: pr.quantity, total: pr.line_item_price(@sale).abs  }
      end
    end
  end
  array.flatten
end

child(:payments) do
  attributes :id, :amount, :created_at, :updated_at
  child(:cashier) do
    attributes :id
    attributes :full_name
  end

  child(:payment_method) do
    attributes :id, :store_id, :name, :xero_code
  end
end
