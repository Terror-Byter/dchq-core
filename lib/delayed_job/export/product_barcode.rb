class DelayedJob::Export::ProductBarcode < Struct.new(:store, :user)
  def perform
    filename = "Product Barcode Export - #{Time.now.strftime("%d/%m/%Y %I:%M%p")}.csv"

    products = CSV.generate do |csv|
      csv << Product.field_names_barcode_export.map(&:last)

      store.products.find_each do |p|
        p.number_in_stock.times do
          csv << [p.name, p.category.name, p.sku_code, p.barcode, p.retail_price, p.description]
        end
      end
    end

    ExportMailer.success(products, filename, I18n.t('controllers.products.product_barcode'), user).deliver
  end
end
