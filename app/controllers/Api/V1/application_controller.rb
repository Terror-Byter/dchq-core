%w(UserNotFound NoAccessToCompany NoAccessToStores StoreNotFound EventNotFound EventIsCancel EventNotAvailable NoAccess
   NoAccessToServiceEdit NoAccessToServices LimitOfActiveSale).each do |exception|
  Object.const_set(exception, Class.new(StandardError))# unless defined?(exception)
end

module Api
  module V1
    class ApplicationController < ActionController::Base

      inherit_resources
      respond_to :json

      resource_description do
        api_version "1.0"
      end

      include CurrentUserInfo

      rescue_from UserNotFound,          with: :user_not_found
      rescue_from NoAccessToCompany,     with: :no_access_to_company
      rescue_from NoAccessToStores,      with: :no_access_to_stores
      rescue_from StoreNotFound,         with: :store_no_found
      rescue_from EventNotFound,         with: :event_not_found
      rescue_from EventIsCancel,         with: :event_is_cancel
      rescue_from EventNotAvailable,     with: :event_not_available
      rescue_from NoAccess,              with: :no_access
      rescue_from NoAccessToServices,    with: :no_access_to_services
      rescue_from NoAccessToServiceEdit, with: :no_access_to_service_edit
      rescue_from LimitOfActiveSale,     with: :limit_of_active_sale

      helper_method :current_user, :current_company, :current_store

      def_param_group :user_token do
        param :user_token, String, desc: 'User Token', required: true
      end

      def_param_group :store_api_key do
        param_group :user_token, Api::V1::ApplicationController
        param :store_api_key, String, desc: 'Store API Key', required: true
      end

      protected
      def authenticate_user_from_token!
        user_token = params[:user_token].presence
        user       = user_token && User.find_by_authentication_token(user_token.to_s)

        if user
          sign_in user, store: false
        else
          raise UserNotFound
        end
      end

      def current_company
        return nil unless current_user
        @current_company ||= current_user.company
      end

      def current_store
        raise UserNotFound unless current_user
        raise NoAccessToStores if available_stores.blank?

        @current_store ||= available_stores.find_by_api_key(params[:store_api_key])
        raise StoreNotFound if @current_store.blank?
        @current_store
      end

      def available_stores
        return nil unless current_company
        @available_stores ||= current_user.stores
      end

      def default_sale_list
        current_store.sales.by_creation.outstanding.not_layby
      end

      def create_sale customer_id = nil
        @sale = Sale.create_empty(current_user, current_store, customer_id || params[:customer_id])
      end

      def no_access_to_company
        render json: { error: 'You do not have access to this company' }, status: 500
      end

      def no_access_to_stores
        render json: { error: 'You do not have access to any stores' }, status: 500
      end

      def store_no_found
        render json: { error: 'Store no found or store_api_key is Invalid' }, status: 500
      end

      def event_not_found
        render json: { error: 'Event not found' }, status: 500
      end

      def event_is_cancel
        render json: { error: 'Event was cancelled' }, status: 500
      end

      def event_not_available
        render json: { error: 'Event not available' }, status: 500
      end

      def no_access
        render json: { error: 'You have no access to this method' }, status: 500
      end

      def no_access_to_services
        render json: { error: 'You have no access to services' }, status: 500
      end

      def no_access_to_service_edit
        render json: { error: 'You have no access to edit the current service' }, status: 500
      end

      def limit_of_active_sale
        render json: { error: 'You have reached the limit of active sales that are still open' }, status: 500
      end

      def user_not_found
        render json: { error: 'Unauthorised' }, status: 401
      end
    end
  end
end
