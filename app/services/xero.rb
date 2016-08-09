class Xero
  attr_reader :store

  def initialize(store)
    @store = store

    if store.xero_connected?
      renew_access_token
      authorize_from_access
      update_tax_rates
      find_or_create_contact
    end
  end

  def xero_config
    @xero_config ||= store.xero
  end

  def renew_access_token
    return if xero_config.expires_at >= 5.minutes.from_now

    response = client.renew_access_token(
      xero_config.xero_consumer_key,
      xero_config.xero_consumer_secret,
      xero_config.xero_session_handle
    )
    
    xero_config.update_attributes(
      xero_consumer_key: response.first,
      xero_consumer_secret: response.last,
      expires_at: 30.minutes.from_now
    )
  end

  def authorize_from_access
    client.authorize_from_access(
      xero_config.xero_consumer_key,
      xero_config.xero_consumer_secret
    )
  end

  def update_tax_rates
    xero_config.update_attributes(
      valid_tax_rate: store.tax_rates.map(&:amount).all? { |e| tax_rates.include?(e) }
    )
  end

  def tax_rates
    @tax_rates ||= client.TaxRate.all.map{|u| u.display_tax_rate.to_f}
  end

  def client
    @client ||= Xeroizer::PartnerApplication.new(
                  Figaro.env.xero_consumer_key,
                  Figaro.env.xero_consumer_secret,
                  Rails.root.join('config', 'xero_keys', 'xero-privatekey.pem'),
                  Rails.root.join('config', 'xero_keys', 'entrust-cert.pem'),
                  Rails.root.join('config', 'xero_keys', 'entrust-private-nopass.pem')
                )
  end

  def send_sales(sales)
    return unless store.xero_connected? || xero_config.valid_tax_rate?

    sales = [sales] unless sales.is_a?(Array)

    invoices = build_invoices(sales)
    client.Invoice.save_records(invoices)

    xero_invoice_ids = invoices.inject({}) do |hash, invoice|
      hash[invoice.invoice_number.to_s.split('-').last] = invoice.invoice_id if invoice.invoice_id
      hash
    end

    xero_invoice_ids.each do |sale_id, invoice_id|
      sale = sales.find { |sale| sale.id == sale.id}
      sale.update_attribute(:xero_invoice_id, invoice_id) if sale
    end

    xero_config.update_attribute(:last_synced_at, Time.now)
  end

  def build_invoices(sales)
    sales.map {|sale| client.Invoice.build(sale.invoice_attributes) }
  end

  def send_payments(sales)
    sales = [sales] unless sales.is_a?(Array)

    payments = sales.map {|sale| sale.generate_payments }.flatten
    payments = build_payments(payments)

    client.Payment.save_records(payments)
  end

  def build_payments(payments)
    payments.map {|payment| client.Payment.build(payment) }
  end

  def send_report(invoice, status = 'SUBMITTED')
    return unless store.xero_connected? || xero_config.valid_tax_rate?
    return send_invoice(invoice, status) if invoice.invoice?
    
    send_credit(invoice, status)
  end

  def send_invoice(invoice, status)
    xero_invoice = client.Invoice.build(invoice.xero_attributes(status))
    begin
      invoice.update_attributes(
        sent: true,
        xero_invoice_id: xero_invoice.id,
        xero_url: "https://go.xero.com/AccountsReceivable/Edit.aspx?InvoiceID=#{xero_invoice.id}"
      ) if xero_invoice.save
    rescue => e
      invoice.errors.add(
        :base,
        Hash.from_xml(e.xml)['ApiException']['Elements']['DataContractBase']['ValidationErrors'].
          to_a.flatten.map{|u| u['Message']}.compact.join(', ')
      )
    end
  end

  def send_credit(invoice, status)
    credit_note = client.CreditNote.build(invoice.xero_attributes(status))
    begin
      invoice.update_attributes(
        sent: true,
        xero_invoice_id: xero_invoice.id,
        xero_url: "https://go.xero.com/AccountsReceivable/EditCreditNote.aspx?creditNoteID=#{credit_note.id}"
      ) if credit_note.save
    rescue => e
      invoice.errors.add(
        :base,
        Hash.from_xml(e.xml)['ApiException']['Elements']['DataContractBase']['ValidationErrors'].
          to_a.flatten.map{|u| u['Message']}.compact.join(', ')
      )
    end
  end

  def delete_report(report)
    return delete_invoice(report.xero_invoice_id) if report.invoice?

    delete_credit(report.xero_invoice_id)
  end

  def delete_invoice(id)
    client.Invoice.find(id).delete!
  end

  def delete_credit(id)
    client.Credit.find(id).delete!
  end

  def find_or_create_contact
    if xero_config.contact_remote_id.blank?
      create_contact
    else
      check_contact_exists
    end
  end

  def create_contact
    contact = client.Contact.create(name: store.name)
    xero_config.update_attribute(:contact_remote_id, contact.contact_id)
  end

  def check_contact_exists
    begin
      client.Contact.find(xero_config.contact_remote_id).blank?
    rescue
      create_contact
    end
  end
end
