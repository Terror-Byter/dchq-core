class StripeService
  def initialize ecp, params
    @ecp = ecp
    @params = params
    @store = @ecp.event.store
    @company = @store.company
  end

  def purchase
    set_current_stripe_key
    charge = Stripe::Charge.create( payment_options )
    #back stripe keys
    set_default_stripe_key
    { success: charge["paid"], token: charge['id'], message: charge["failure_message"]}
  end

  private
  def payment_options
    { amount: (@ecp.price * 100).to_i,
      currency: @store.currency.code,
      card: @params[:stripe_card_token],
      description: "#{@ecp.event.name} - created by #{@ecp.customer.full_name} on #{@ecp.created_at.strftime("%d/%m/%Y %I:%M%P")}"
    }
  end

  def set_default_stripe_key
    Stripe.api_key = Figaro.env.stripe_api_key
  end

  def set_current_stripe_key
    Stripe.api_key = @company.payment_credential.stripe_secret_key
  end
end
