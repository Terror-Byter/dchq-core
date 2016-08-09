class DelayedJob::Export::Sale < Struct.new(:store, :user, :start_date, :end_date)
  def perform
    filename = "Financial_Records-#{Time.now.strftime("%d%m%Y-%I:%M%p")}.csv"
    
    finance_file = CSV.generate do |csv|
      csv << header

      sales.each do |sale|
        array = []
        array << [
          sale.id,
          sale.created_at,
          sale.status,
          sale.customers.map(&:full_name).join(" | "),
          sale.customers.map(&:id).join(" | "),
          sale.grand_total.to_f,
          sale.tax_rate_total.to_f
        ]

        sp = sale.sale_products.includes([:sale_productable, :sale])
        maximum_sale_products.times do |i|
          if sp[i].try(:sale_productable)
            array << [
              sp[i].try(:sale_productable).try(:name),
              sp[i].try(:sale_productable).try(:sku_code),
              sp[i].try(:quantity),
              (sp[i].blank? || sp[i].try(:unit_price).to_f.zero? || sp[i].try(:quantity).to_f.zero?) ?
                0 :
                sp[i].try(:unit_price).try(:to_f) / sp[i].try(:quantity).to_f, sp[i].try(:tax_rate_amount).try(:to_f)
            ]
          else
            array << ['']*5
          end
        end

        spay = sale.payments
        maximum_payments.times do |i|
          array << [
            spay[i].try(:payment_method).try(:name), spay[i].try(:amount), spay[i].try(:created_at)]
        end

        csv << array.flatten
      end
    end
    ExportMailer.success(finance_file, filename, I18n.t('activerecord.models.sale.one'), user).deliver
  end

  def maximum_sale_products
    @maximum_sale_products ||= begin
      max_products_sale_id = SaleProduct.joins(:sale).where(
        sale_id: sales.map(&:id)
      ).select(:sale_id).group(:sale_id).order("count(sale_id) desc").first.try(:sale_id)

      maximum_sale_products = Sale.find_by_id(max_products_sale_id).sale_products.count if max_products_sale_id
      maximum_sale_products ||= 0

      maximum_sale_products
    end
  end

  def maximum_payments
    @maximum_payments ||= begin
      max_payments_sale_id = Payment.joins(:sale).where(
        sale_id: sales.map(&:id)
      ).select(:sale_id).group(:sale_id).order("count(sale_id) desc").first.try(:sale_id)

      maximum_payments = Sale.find_by_id(max_payments_sale_id).payments.count if max_payments_sale_id
      maximum_payments ||= 0

      maximum_payments
    end
  end

  def header
    [
      'Sale ID',
      'Date',
      'Sale Status',
      'Customer Name(s)',
      'Customer ID(s)',
      'Sale Grand Total',
      'Sale Tax Total'
    ].tap do |header|
      maximum_sale_products.times do |i|
        header << [
          "Product Name #{ i.next }",
          "Product SKU #{ i.next }",
          "Product Quantity #{ i.next }",
          "Product Price #{ i.next }",
          "Product Tax #{ i.next }"
        ]
      end

      maximum_payments.times do |i|
        header << [
          "Payment Type #{ i.next }",
          "Payment Amount #{ i.next }",
          "Payment Date #{ i.next }"
        ]
      end
    end.flatten
  end


  def sales
    @sales ||= store.sales.includes(
      :customers,
      :store,
      sale_customers: [:customer],
      sale_products: [:sale_productable],
      payments: [:payment_method]
    ).where(created_at: start_date.to_datetime..end_date.to_datetime)
  end
end
