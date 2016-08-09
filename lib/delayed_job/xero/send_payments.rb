class DelayedJob::Xero::SendPayments < Struct.new(:sale_id)
  def perform
    sale = Sale.find(sale_id)
    xero = ::Xero.new(sale.store)
    
    xero.send_payments(sale)
  end
end
