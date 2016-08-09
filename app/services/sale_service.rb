class SaleService
  def initialize ecp, params
    @ecp         = ecp
    @params      = params
    @store   = ecp.event.store
    @company = @store.company
  end

  def create_for_booking
    @ecp.update_attribute :status, nil

    sale_booking.add_events!(ecp_id: @ecp.id, customer_id: @ecp.customer.id)
    sale_booking.payments.build payment_options

    sale_booking.save
    sale_booking.update_attributes status: "complete", booking: true

    @ecp.send_bookings_paid_emails
  end

  private
  def sale_booking
    @sale ||= Sale.create_empty(@company.owner, @store, @ecp.customer.id)
  end

  def payment_options
    { cashier_id: @company.owner.id,
      payment_method_id: @store.payment_methods.send(@params[:payment_type]).first.id,
      amount: @ecp.price,
      payment_transaction: @params[:token] }
  end
end
