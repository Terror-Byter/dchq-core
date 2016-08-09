module Api
  module V1
    class PagesController < Api::V1::ApplicationController
      actions :index

      api :GET, '/v1/pages', 'Return short sale information for dashboard'
      param_group :user_token, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https:://app.divecentrehq.com/api/v1/pages

      # Request Body
      {
        user_token: <USER_TOKEN>,
      }

      ########### Response Example ################
      {
       user_token: <USER_TOKEN>,
        user: {
          id: 2,
          full_name: "John Ricketts",
          created_at: "2013-10-14T12:47:35Z",
          sale_target: "2000.0",
          sales: {
            current_sale_target: "423.33",
            last_week: "196.37",
            this_week: "20.0"
          }
        }
      }
      '
      def index
        @user = current_user
      end

      private
      def begin_of_association_chain
        current_company
      end
    end
  end
end
