class DelayedJob::Import::Eve < Struct.new(:file_path, :store, :user)
  attr_accessor :current_sheet, :current_sale

  def perform
    return unless File.exist?(file_path)
    Sale.transaction do
      table.each_with_pagename do |name, sheet|
        @current_sheet = sheet
        invoice_id = nil
        2.upto(current_sheet.last_row) do |line|
          if current_sheet.cell(line, 'AM') != invoice_id
            invoice_id = current_sheet.cell(line, 'AM')
            if current_sale
              finalize_sale(line)
            end
            create_sale(line)
          end
          add_product(line)
        end

        finalize_sale(current_sheet.last_row)
      end
    end
    # File.delete(file_path)
  end

  private

  def table
    @table ||= open_spreadsheet(file_path)
  end

  def open_spreadsheet(file)
    case File.extname(file)
    when '.xls' then
      Roo::Excel.new(file)
    when '.xlsx' then
      Roo::Excelx.new(file)
    when '.ods' then
      Roo::OpenOffice.new(file)
    else
      raise "Unknown file type: #{file}"
    end
  end

  def create_sale(line)
    customer = customers(
      current_sheet.cell(line, 'DG'),
      {
        given_name: current_sheet.cell(line, 'AZ'),
        family_name: current_sheet.cell(line, 'BB'),
        email: current_sheet.cell(line, 'BM'),
        gender: current_sheet.cell(line, 'BQ'),
        mobile_phone: current_sheet.cell(line, 'BL'),
        telephone: current_sheet.cell(line, 'BJ')
      },
      {
        first: [current_sheet.cell(line, 'BC'), current_sheet.cell(line, 'BD')].join(' '),
        second: [current_sheet.cell(line, 'BE'), current_sheet.cell(line, 'BF')].join(' '),
        post_code: current_sheet.cell(line, 'BH')
      }
    )

    @current_sale = Sale.new do |sale|
      sale.store_id = store.id
      sale.creator = cashier
      sale.created_at = current_sheet.cell(line, 'AQ') || Time.now
      sale.save
    end

    current_sale.sale_customers.create(customer: customer)
  end

  def add_product(line)
    product = products(line)

    return unless product.persisted?
    return if current_sheet.cell(line, 'D').zero?

    current_sale.sale_products.create! do |sale_product|
      sale_product.sale_productable_id = product.id
      sale_product.sale_productable_type = product.class.name
      sale_product.quantity = current_sheet.cell(line, 'D')
      sale_product.price = formatted_price(current_sheet.cell(line, 'L') / current_sheet.cell(line, 'D'))
    end
  end

  def finalize_sale(line)
    current_sale.freeze_product_prices
    current_sale.update_attributes!(
      taxable_revenue: current_sale.send(:calc_taxable_revenue),
      cost_of_goods: current_sale.send(:calc_cost_of_goods)
    )

    current_sale.sale_products.each do |sp|
      sp.update_attribute(:smart_line_item_price, sp.line_item_price)
    end

    add_payment(current_sale, cashier)

    current_sale.update_attributes(
      status: 'complete',
      completed_at: current_sheet.cell(line, 'AQ') || Time.now
    )
  end

  def customers(cust_id, options = {}, address = {})
    options.reverse_merge!(company_id: store.company_id)

    cached(:customers, cust_id) do
      Customer.where(options.slice(:given_name, :family_name, :company_id)).
        first_or_create(options).tap do |customer|
        unless customer.address
          customer.build_address
          address.each do |k, v|
            customer.address[k] = v
          end
          customer.address.save
        end
        customer.avatar = Image.create unless customer.avatar
      end
    end
  end

  def products(line)
    sku = current_sheet.cell(line, 'C').to_s
    name = current_sheet.cell(line, 'B').gsub(/\(.*?\)/, '')

    return unless name

    cached(:products, sku) do
      Product.where(sku_code: sku, store_id: store.id).first_or_create do |p|
        p.archived = true
        p.commission_rate_money = 0
        p.category = categories(current_sheet.cell(line, 'F'))
        p.brand = brands(current_sheet.cell(line, 'G'))
        p.supplier = supplier
        p.tax_rate = tax_rate
        p.sku_code = sku
        p.name = name
        p.supply_price = formatted_price(current_sheet.cell(line, 'AD'))
        p.retail_price = p.supply_price
        p.logo = Image.create unless p.logo
      end
    end
  end

  def categories(name)
    name = name.presence || 'Not Set'

    cached(:categories, name) do
      ::Category.where(name: name, store_id: store.id).first_or_create
    end
  end

  def brands(name)
    name = name.presence || 'Not Set'
    cached(:brands, name) do
      ::Brand.where(name: name, store_id: store.id).first_or_create
    end
  end

  def supplier
    @supplier ||= ::Supplier.where(name: 'Not Set', company_id: store.company_id).first_or_create
  end

  def tax_rate
    @tax_rate ||= ::TaxRate.where(amount: '0', store_id: store.id).first_or_create
  end

  def add_payment(sale, cashier)
    Payment.create(
      created_at: sale.created_at,
      cashier_id: cashier.id,
      sale_id: sale.id,
      payment_method_id: payment_method.id,
      amount: formatted_price(sale.sub_total)
    )
  end

  def payment_method
    @payment_method ||= PaymentMethod.where(name: 'Cash', store_id: store.id).first_or_create
  end

  def cashier
    @creator ||= User.where(company_id: store.company_id, role: Role::MANAGER).first_or_create do |u|
      u.given_name = 'First'
      u.family_name = 'Manager'
      u.password = (0...8).map { (65 + rand(26)).chr }.join
      u.email = "store#{store.id}@divecentrehq.com"
      u.avatar = Image.create unless u.avatar
      u.address = Address.create unless u.address
    end
  end

  def formatted_price(price)
    BigDecimal.new(price.to_s.tr('^0-9\,\.', ''))
  end

  def cached(key, id)
    @memoize_cache ||= Hash.new { |h, k| h[k] = {} }
    @memoize_cache[key][id] ||= yield
  end

end
