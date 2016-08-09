collection :@sales

attributes :id, :created_at, :grand_total, :status
child :customers do
  attributes :id, :full_name
end

node(:number_of_products) { |sale| sale.sale_products.only_products.sum(:quantity) }
node(:number_of_services) do |sale|
  sale.products.any? ? sale.sale_products.only_services.sum(:quantity) : 0
end
node(:number_of_gift_cards) { |sale| sale.sale_products.gift_cards.count }
node(:number_of_events) { |sale| sale.event_customer_participants.count }
