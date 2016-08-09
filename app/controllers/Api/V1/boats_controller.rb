module Api
  module V1
    class BoatsController < Api::V1::ApplicationController
      actions :index
      defaults resource_class: Stores::Boat, collection_name: 'boats', instance_name: 'boat'

      api :GET, '/v1/boats', 'Boats list for specific store'
      param_group :store_api_key, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/boats

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <store_API_KEY>
      }

      ########### Response Example ################
      {
        "boats": [
          {
            "id": 13,
            "name": "Captain Haddock"
          },
          {
            "id": 23,
            "name": "Green Eyed Lady"
          }
        ]
      }
      '
      def index
        super
      end

      protected
      def begin_of_association_chain
        current_store
      end
    end
  end
end
