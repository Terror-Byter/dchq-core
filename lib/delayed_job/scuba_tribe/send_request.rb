class DelayedJob::ScubaTribe::SendRequest < Struct.new(:sale_id)
  def perform
    sale = Sale.find(sale_id)
    store = sale.store

    return unless store.scubatribe_connected?
    return unless sale.sale_products.
      any? { |sp| sp.sale_productable_type == 'EventCustomerParticipant' }

    customer = sale.customers.first

    ::ScubaTribe.new(sale.store.scuba_tribe.api_key).send_request(
      sale_id,
      email: customer.email,
      first_name: customer.given_name,
      last_name: customer.family_name
    )
  end
end
