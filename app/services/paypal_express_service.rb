class PaypalExpressService

  def initialize ecp, params = {}, request = {}
    @ecp = ecp
    @store = @ecp.event.store
    @company = @store.company
    @params = params
    @request = request
  end

  def response
    @response ||= gateway.setup_purchase((@ecp.price.to_f * 100).to_i,
                           ip: @request.remote_ip,
                           return_url: @ecp.decorate.paypa_booking_complete( @params[:public_key] ),
                           cancel_return_url: @ecp.decorate.cancel_booking( @params[:public_key] ),
                           currency: @store.currency.code.html_safe,
                           items: [{
                             name: @ecp.event.name,
                             description: "#{@ecp.event.name} on #{@ecp.event.starts_at.strftime("%d %B, %Y at %I:%M%P")}",
                             quantity: 1,
                             amount: @ecp.price.to_f * 100 }]
                           )

  end

  def gateway
    @gateway ||= ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
  end

  def pay
    gateway.purchase(@ecp.price.to_f * 100, ip: @request.remote_ip, payer_id: @params[:PayerID], token: @params[:token], currency: @store.currency.code)
  end

  private
  def paypal_options
    { login:     @company.payment_credential.paypal_login,
      password:  @company.payment_credential.paypal_password,
      signature: @company.payment_credential.paypal_signature,
      allow_guest_checkout: true }
  end

end
