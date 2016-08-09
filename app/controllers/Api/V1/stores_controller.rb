module Api
  module V1
    class StoresController < Api::V1::ApplicationController
      actions :index

      api :GET, '/v1/stores', 'Get available stores list for user'
      param_group :user_token, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://api.divecentrehq.com/api/v1/stores

      # Request Body
      {
        user_token: <USER_TOKEN>,
      }

      ########### Response Example ################
      {
        "stores": [
          {
            "name": "Test Store",
            "api_key": "store_api_key",
            "currency":
              {
                "id": 1,
                "name": "US Dollar",
                "unit": "$",
                "code": "USD",
                "separator": ".",
                "delimiter": ",",
                "format": "%u%n",
                "precision": 2
              }
          }
        ]
      }
      '
      def index
        super
      end

      private
      def begin_of_association_chain
        current_company
      end
    end
  end
end
