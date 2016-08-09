class Invoices
  attr_reader :file_path, :store
  attr_accessor :current_sheet

  DEFAULT_FAMILY_NAME = '.'

  def initialize(file_path, store_id)
    @file_path = file_path
    @store = Store.find(store_id)
  end

  def import
    Sale.transaction do
      table.each_with_pagename do |name, sheet|
        next if name.downcase == 'summary'
        @current_sheet = sheet
        5.upto(current_sheet.last_row) do |line|
          next unless current_sheet.cell(line, 3)
          next unless current_sheet.cell(line, 2).is_a?(Date)

          sale(line)
        end
      end
    end
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

  def sale(line)
    customer = customers(current_sheet.cell(line, 1))
    product = products(
      current_sheet.cell(line, 3),
      current_sheet.cell(line, 4) || current_sheet.cell(line, 5)
    )

    return unless product.persisted?

    Sale.new do |sale|
      sale.store_id = store.id
      sale.creator = creator
      sale.created_at = current_sheet.cell(line, 2) || Time.now
      sale.note = note(line)
      sale.save

      sale.sale_products.create do |sale_product|
        sale_product.sale_productable_id = product.id
        sale_product.sale_productable_type = product.class.name
        sale_product.quantity = 1
      end
      sale.sale_customers.create(customer: customer)

      add_payment(current_sheet.cell(line, 4), current_sheet.cell(line, 5), sale)

      sale.freeze_product_prices
      sale.update_attributes!(
        taxable_revenue: sale.send(:calc_taxable_revenue),
        cost_of_goods: sale.send(:calc_cost_of_goods)
      )

      sale.sale_products.each do |sp|
        sp.update_column(:smart_line_item_price, sp.line_item_price)
      end

      sale.update_attributes(
        status: 'complete',
        completed_at: current_sheet.cell(line, 2) || Time.now
      )
    end
  end

  def note(line)
    {
      'Invoice Book Receipt No:' => current_sheet.cell(line, 6).to_s.split('.')[0],
      'Duty Free:' => current_sheet.cell(line, 7),
      'Duty Paid:' => current_sheet.cell(line, 8),
      'Comments:' => current_sheet.cell(line, 9)
    }.select { |k, v| v.present? }.map { |k, v| "#{k} #{v}" }.join('<br>')
  end

  def customers(name)
    name ||= 'Walk In'
    given_name, family_name = name.split(' ')

    cached(:customers, name) do
      Customer.where(
        given_name: given_name,
        family_name: family_name || DEFAULT_FAMILY_NAME,
        company_id: store.company.id
      ).first_or_create.tap do |customer|
        customer.avatar = Image.create unless customer.avatar
        customer.address = Address.create unless customer.address
      end
    end
  end

  def products(name, price)
    return unless name
    sku = sku_code(name)

    cached(:products, sku) do
      Product.where(sku_code: sku, store_id: store.id).first_or_create do |p|
        p.archived = true
        p.commission_rate_money = 0
        p.category = category
        p.brand = brand
        p.supplier = supplier
        p.tax_rate = tax_rate
        p.sku_code = sku
        p.name = name
        p.supply_price = formatted_price(price)
        p.retail_price = p.supply_price
        p.logo = Image.create unless p.logo
      end
    end
  end

  def category
    @category ||= Category.where(name: 'Not Set', store_id: store.id).first_or_create
  end

  def brand
    @brand ||= Brand.where(name: 'Not Set', store_id: store.id).first_or_create
  end

  def supplier
    @supplier ||= Supplier.where(name: 'Not Set', company_id: store.company_id).first_or_create
  end

  def tax_rate
    @tax_rate ||= TaxRate.where(amount: '10', store_id: store.id).first_or_create
  end

  def add_payment(card_amount, cash_amount, sale)
    amount = card_amount || cash_amount
    return unless amount
    payment_name = card_amount.present? ? :card : :cash
    Payment.create(
      created_at: sale.created_at,
      cashier_id: creator.id,
      sale_id: sale.id,
      payment_method_id: payment_method(payment_name).id,
      amount: formatted_price(amount)
    )
  end

  def payment_method(name)
    name = { card: 'Credit Card', cash: 'Cash' }[name]
    cached(:payment_methods, name) do
      PaymentMethod.where(name: name, store_id: store.id).first_or_create
    end
  end

  def creator
    @creator ||= User.where(company_id: store.company_id, role: Role::MANAGER).first_or_create do |u|
      u.given_name = 'First'
      u.family_name = 'Manager'
      u.password = (0...8).map { (65 + rand(26)).chr }.join
      u.email = "store#{store.id}@divecentrehq.com"
      u.avatar = Image.create unless u.avatar
      u.address = Address.create unless u.address
    end
  end

  def sku_code(name)
    name.gsub(/\s+/, '_') #.gsub(/[^[:alpha:]]/, '')
  end

  def formatted_price(price)
    BigDecimal.new(price.to_s.tr('^0-9\,\.', ''))
  end

  def cached(key, id)
    @memoize_cache ||= Hash.new { |h, k| h[k] = {} }
    @memoize_cache[key][id] ||= yield
  end
end
