object :@product

attributes :id, :accounting_code, :archived, :barcode, :commission_rate_money,
           :description, :low_inventory_reminder, :markup, :name, :number_in_stock,
           :offer_price, :retail_price, :sent_at, :sku_code, :supplier_code,
           :supply_price

node :image do |product|
  product.logo.image.url
end

child(:brand)           { attributes :id, :name }
child(:category)        { attributes :id, :name }
child(:supplier)        { attributes :id, :name }
child(:commission_rate) { attributes :id, :amount }
child(:tax_rate)        { attributes :id, :amount }
