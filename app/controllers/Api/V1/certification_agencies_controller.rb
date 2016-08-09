module Api
  module V1
    class CertificationAgenciesController < Api::V1::ApplicationController
      actions :index, :show

      api :GET, '/v1/certification_agencies', 'List of all certification agencies'
      param_group :user_token, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/certification_agencies

      # Request Body
      {
        user_token: <USER_TOKEN>,
      }

      ########### Response Example ################
      {
        "certification_agencies": [
          {
            "id": 1,
            "name": "PADI"
          },
          {
            "id": 2,
            "name": "BSAC"
          }
        ]
      }
      '
      def index
        super
      end

      api :GET, '/v1/certification_agencies/:id', 'Details about certification_agency'
      param :id, Integer, desc: "Certification Agency ID", required: true
      param_group :store_api_key, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/certification_agencies/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
      }

      ########### Response Example ################
      {
        "certification_agency":
          {
            "id": 1,
            "name": "PADI",
            "certification_levels": [
              {
                "id": 205,
                "name": "Open Water Diver"
              }
            ]
          }
      }
      '
      def show
        super
      end
    end
  end
end
