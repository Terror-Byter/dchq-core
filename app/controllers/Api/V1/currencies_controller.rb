module Api
  module V1
    class CurrenciesController < Api::V1::ApplicationController
      skip_before_filter :authenticate_user_from_token!
      actions :index

      api :GET, '/v1/currencies', 'Return list of all currencies'
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/currencies

      # Request Body
      {
      }

      ########### Response Example ################
      {
        currencies: [
          {
            code: "USD",
            created_at: "2010-12-30T19:57:00Z",
            delimiter: ",",
            format: "%u%n",
            id: 1,
            name: "US Dollar",
            precision: 2,
            separator: ".",
            unit: "$",
            updated_at: "2010-12-30T19:57:00Z"
          },
          {
            code: "GBP",
            created_at: "2010-12-30T20:01:00Z",
            delimiter: ",",
            format: "%u%n",
            id: 2,
            name: "British Pound",
            precision: 2,
            separator: ".",
            unit: "&pound;",
            updated_at: "2011-06-19T22:16:00Z"
          }
        ]
      }
      '
      def index
        super
      end
    end
  end
end
