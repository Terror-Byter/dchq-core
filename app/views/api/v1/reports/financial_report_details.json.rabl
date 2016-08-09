object :@financial_report

attributes :id, :sent
node(:type){ |financial_report| financial_report.class.name.gsub("Stores::", '') }
node(:completed_sales){ |financial_report| formatted_currency(financial_report.complete_payments) }
node(:tax_total){ |financial_report| formatted_currency(financial_report.tax_total) }
node(:discounts){ |financial_report| formatted_currency(financial_report.discounts) }
node(:total_payments){ |financial_report| formatted_currency(financial_report.total_payments) }

child(:store) { attributes :id, :name }
child(:working_time) do
  attributes :open_at, :close_at
end

node(:category_payments){ |financial_report| financial_report.decorate.category_payments }
node(:payments_for_complete_sales){ |financial_report| financial_report.decorate.payments_for_complete_sales }
node(:payments_for_layby_sales){ |financial_report| financial_report.decorate.payments_for_layby_sales }
node(:tills){ |financial_report| financial_report.decorate.tills }
