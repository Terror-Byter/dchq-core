module Api
  module V1
    class TaxRatesController < Api::V1::ApplicationController
      actions :index

      api :GET, '/v1/tax_rates', 'Get all tax rates for store'
      param_group :store_api_key, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://api.divecentrehq.com/api/v1/tax_rates

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
      }

      ########### Response Example ################
      {
        "tax_rates": [
          {
            "id": 1,
            "amount": 0.0,
            "created_at": "2012-02-02T12:34:49+00:00",
            "updated_at": "2014-06-06T11:30:30+01:00",
            "identifier": "",
            "deleted_at": null
          },
          {
            "id": 2,
            "amount": 7.0,
            "created_at": "2012-02-09T00:31:24+00:00",
            "updated_at": "2013-04-22T16:48:11+01:00",
            "identifier": "",
            "deleted_at": null
          },
          {
            "id": 3,
            "amount": 4.712,
            "created_at": "2014-07-11T14:41:05+01:00",
            "updated_at": "2014-09-02T20:47:38+01:00",
            "identifier": "",
            "deleted_at": null
          }
        ]
      }
      '
      def index
        super
      end

      private
      def begin_of_association_chain
        current_store
      end
    end
  end
end
