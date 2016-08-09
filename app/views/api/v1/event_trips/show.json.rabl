object :@event_trip

attributes :id, :name, :cost, :commission_rate_money, :exclude_tariff_rates, :local_cost
child :tax_rate do
  attributes :id, :amount
end

child :commission_rate do
  attributes :id, :amount
end
