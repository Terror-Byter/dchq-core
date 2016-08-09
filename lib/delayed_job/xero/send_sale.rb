class DelayedJob::Xero::SendSale < Struct.new(:sale_id)
  def perform
    sale = Sale.find(sale_id)
    xero = ::Xero.new(sale.store)
    xero.send_sales(sale)

    Delayed::Job.enqueue(DelayedJob::Xero::SendPayments.new(sale_id))
  end
end
