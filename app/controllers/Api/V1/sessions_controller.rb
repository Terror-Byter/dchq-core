module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_filter :authenticate_user_from_token!

      respond_to :json

      api :POST, '/v1/sessions', 'Sign In user'
      param :user, Hash, required: true, action_aware: true do
        param :email, String, desc: 'User email', required: true
        param :password, String, desc: 'User password', required: true
      end
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/sessions

      #Request Body
      {
        user: {
          email: "email@example.com",
          password: "password"
        }
      }

      ########### Response Example ################
      #SUCCESS
      {
        success: true,
        info: "Logged in",
        data: {
          user_token: <USER_TOKEN>
        }
      }

      #FAILURE
      {
        error: "Invalid email or password."
      }
      '
      def create
        resource = warden.authenticate!(auth_options)
        if resource
          render :status => 200,
            :json => { :success => true,
                       :info => "Logged in",
                       :data => { :user_token => resource.authentication_token } }
        else
          failure
        end
      end

      private
      def failure
        render :status => 401,
          :json => { :success => false,
                     :info => "Login Failed",
                     :data => {} }
      end
    end
  end
end
