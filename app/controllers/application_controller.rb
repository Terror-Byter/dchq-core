class ApplicationController < ActionController::Base
  protect_from_forgery

  require 'csv'
  require 'qif'

  require 'barby'
  require 'barby/barcode/code_39'
  require 'barby/outputter/svg_outputter'
  require 'barby/outputter/html_outputter'
  require 'zebra_printer'

  include CurrentUserInfo
  include CurrentStoreInfo

  before_filter :authenticate_user!
  before_filter :check_registration_is_completed, unless: :devise_controller?
  before_filter :set_pos_card_referer_flag
  before_filter :check_available_shops
  before_filter :set_timezone, :set_locale, :set_current_user, :set_current_store, :set_currency_for_js

  helper_method :current_company, :current_store, :available_stores, :default_sale_list

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def current_user
    UserDecorator.decorate(super) unless super.nil?
  end

  def default_sale_list
    @default_sale_list ||= current_store.sales.includes(:customers).by_creation.outstanding.not_layby
  end

  private
  def set_timezone
    Time.zone = current_store.time_zone unless current_store.blank?
  end

  def set_locale
    I18n.locale = user_signed_in? ? current_user.locale.to_sym : :en
  end

  def check_registration_is_completed
    return if current_user && (current_user.finished? || (current_user.step_3? && params[:controller].to_sym.eql?(:pages) && params[:action].to_sym.eql?(:complete_setup)))
    is_update_store_path = params[:controller].to_sym.eql?(:stores) && params[:action].to_sym.eql?(:update)
    is_registration_in_progress = current_user && !current_user.finished? && !is_update_store_path

    redirect_to edit_user_registration_path if is_registration_in_progress
  end

  def current_company
    return nil unless current_user

    @current_company ||= CompanyDecorator.decorate(Company.find(current_user.company_id))
  end

  def current_store
    return @current_store if @current_store
    store_id ||= if params[:public_key]
                   Store.find_by_public_key(params[:public_key]).try(:id)
                 else
                   available_stores.try(:first).try(:id)
                 end
    @current_store = StoreDecorator.decorate(Store.find_by_id(store_id) || Store.find_by_public_key(params[:public_key]))
  end

  def available_stores
    return nil unless current_company

    @available_stores ||= current_user.stores
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def set_pos_card_referer_flag
    @is_pos_card_referer_sales = /\/sales/ === request.env["HTTP_REFERER"]
  end

  def check_available_shops
    if current_user
      if current_user.stores.blank?
        redirect_to no_access_pages_path , error: I18n.t("controllers.application.check_available_shops")
        return
      end
    end
  end

  def create_sale customer_id = nil
    @sale = Sale.create_empty(current_user, current_store, customer_id || params[:customer_id])
  end

  def check_current_user_access
    redirect_to settings_path, alert: I18n.t("controllers.check_access") unless current_user.manager?
  end

  def set_current_user
    return unless current_user
    CurrentUserInfo.current_user_info = current_user
  end

  def set_current_store
    CurrentStoreInfo.current_store_info = current_store
  end

  def set_currency_for_js
    gon.currency   = current_store.blank? ? '$' : current_store.currency.unit
  end
end
