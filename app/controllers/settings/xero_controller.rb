class Settings::XeroController < InheritedResources::Base

  respond_to :html, :js
  actions :update
  custom_actions collection: [:edit_xero, :connect_to_xero, :disconnect, :callback, :update_settings, :check_xero_tax_rates]

  before_filter :check_current_user_access
  before_filter :set_xero, except: [:disconnect]

  def edit_xero
    if current_store.xero.batch?
      current_store.xero.integration_type = 'individual'
      current_store.xero.integration_type_individual = 'batch'
    end
  end

  def check_xero_tax_rates
  end

  def update_settings
    if params[:store][:xero_attributes][:integration_type] == 'individual'
      params[:store][:xero_attributes][:integration_type] = params[:store][:xero_attributes][:integration_type_individual]
    end

    if current_store.update_attributes(params[:store])
      redirect_to edit_xero_settings_xero_path, notice: "Xero settings were saved successfully"
    else
      render action: :edit_xero
    end
  end

  def sync
    if current_store.xero.last_synced_at && current_store.xero.last_synced_at > 4.hours.ago
      redirect_to edit_xero_settings_xero_path, error: 'Batch sync with Xero has not been possible. You can only run a batch process once every 4 hours.'
      return
    end

    sales = current_store.sales.completed.where('created_at >= ?', current_store.xero.last_synced_at)

    @xero.send_sales(sales.to_a)
    @xero.send_payments(sales.reload.to_a)

    rentals = current_store.rentals.where(status: 'completed').where('created_at >= ?', current_store.xero.last_synced_at)

    @xero.send_sales(rentals.to_a)
    @xero.send_payments(rentals.reload.to_a)

    redirect_to edit_xero_settings_xero_path, notice: 'Sales data has been successfully synced with Xero'
  end

  def connect_to_xero
    request_token = @xero.client.request_token(
      oauth_callback: callback_settings_xero_url
    )

    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret

    redirect_to request_token.authorize_url
  end

  def callback
    @xero.client.authorize_from_request(
      session[:request_token],
      session[:request_secret],
      oauth_verifier: params[:oauth_verifier]
    )

    current_store.xero.update_attributes(
      xero_session_handle: @xero.client.session_handle,
      xero_consumer_key: @xero.client.access_token.token,
      xero_consumer_secret: @xero.client.access_token.secret,
      expires_at: @xero.client.expires_at
    )

    redirect_to action: :edit_xero
  end

  def disconnect
    current_store.xero.update_attributes(
      xero_session_handle: nil,
      xero_consumer_key: nil,
      xero_consumer_secret: nil
    )

    current_store.payment_methods.update_all(xero_code: nil)
    redirect_to action: :edit_xero
  end

  def set_xero
    @xero = Xero.new(current_store)
  end
end
