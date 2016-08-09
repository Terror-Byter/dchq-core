class BookingsController < InheritedResources::Base

  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  defaults resource_class: Event

  respond_to :html
  respond_to :json, only: :calculate_price
  skip_filter :authenticate_user!

  custom_actions collection: [:step_1, :step_2, :cancel, :paypal_complete, :calculate_price ]

  before_filter :detect_store

  def step_1
    unless @event = @current_store.events.find_by_id(params[:event_id])
      render text: I18n.t('controllers.bookings.cannot_find_event') and return
    end

    render text: I18n.t('controllers.bookings.event_unavailabe') and return unless @event.available?
    @ecp = @event.event_customer_participants.build
    render layout: 'bookings'
  end

  def calculate_price
    event = @current_store.events.find_by_id(params[:event_id])
    render json: { errors: I18n.t('controllers.bookings.cannot_find_event') } and return unless event

    ecp = event.event_customer_participants.build(params[:event_customer_participant])

    customer = @current_company.customers.find_by_email(params[:customer_email])
    ecp.customer = customer if customer

    render json: { insurance:        formatted_currency(ecp.insurance_price),
                   kit_hire:         formatted_currency(ecp.kit_hire_price),
                   transport:        formatted_currency(ecp.transports_price),
                   additionals:      formatted_currency(ecp.additionals_price),
                   event_text_price: formatted_currency(ecp.event_line_item_price),
                   total_price:      formatted_currency(ecp.grand_total_price_with_default_discount),
                   discount:         ecp.show_discount
                  }
  end

  def step_2
    @event = @current_store.events.find_by_id(params[:event_id])
    render text: I18n.t('controllers.bookings.cannot_find_event') and return unless @event

    @ecp = @event.event_customer_participants.build(params[:event_customer_participant])
    @ecp[:need_show] = true
    @ecp[:customer_id] = @current_company.customers.find_by_email(params[:customer_email]).try(:id)

    if @ecp.save
      if params[:certification_level_id]
        @ecp.customer.certification_level_memberships.create(certification_level_id: params[:certification_level_id],
                                                             certification_agency_id: params[:certification_agency_id],
                                                             membership_number: params[:membership_number],
                                                             primary: true,
                                                             certification_date: params[:certification_date]
                                                            )
      end

      if params[:stripe_card_token]
        pay_with_stripe
      elsif params[:button] == 'paypal'
        pay_with_paypal
      elsif params[:button] == 'epay'
        pay_with_epay
      else
        @ecp.send_bookings_not_paid_emails
        render template: 'bookings/complete'
      end
    else
      render action: :step_1
    end
  end

  def paypal_complete
    @ecp = @current_store.customer_participants.find_by_id(params[:event_customer_participant_id])

    paypal_express = PaypalExpressService.new @ecp, params, request

    purchase = paypal_express.pay

    if purchase.success?
      sale_service = SaleService.new @ecp, params
      sale_service.create_for_booking
      @ecp.reload
      CurrentStoreInfo.current_store_info = @current_store
      render template: 'bookings/complete'
    else
      redirect_to cancel_bookings_url(public_key: params[:public_key], message: purchase.message, ecp_id: @ecp.id )
    end
  end

  def cancel
    @ecp = @current_store.customer_participants.find(params[:ecp_id])
  end

  private
  def detect_store
    if @current_store = Store.find_by_public_key(params[:public_key])
      @current_company = @current_store.company
      render text: I18n.t('controllers.bookings.no_booking')
    else
      render text: I18n.t('controllers.bookings.incorrect_public_key') and return
    end
  end

  def pay_with_paypal
    paypal_express = PaypalExpressService.new @ecp, params, request

    redirect_to paypal_express.gateway.redirect_url_for(paypal_express.response.token)
  end

  def pay_with_stripe
    stripe = StripeService.new @ecp, params
    purchase = stripe.purchase

    if purchase[:success]
      params.merge!({ payment_type: 'stripe', token: purchase[:token] })
      sale_service = SaleService.new @ecp, params
      sale_service.create_for_booking
      @ecp.reload
      CurrentStoreInfo.current_store_info = @current_store
      render template: 'bookings/complete'
    else
      redirect_to cancel_bookings_url(public_key: params[:public_key], message: purchase[:message], ecp_id: @ecp.id )
    end
  end

  def pay_with_epay
    epay = EpayService.new @ecp, params
    transaction = epay.purchase

    if transaction.kind_of?(Epay::Transaction) && transaction.success?
      params.merge!({ payment_type: 'Epay', token: 'Epay' })
      sale_service = SaleService.new @ecp, params
      sale_service.create_for_booking
      @ecp.reload
      CurrentStoreInfo.current_store_info = @current_store
      render template: 'bookings/complete'
    else
      redirect_to cancel_bookings_url(public_key: params[:public_key], message: transaction[:error], ecp_id: @ecp.id )
    end
  end
end
