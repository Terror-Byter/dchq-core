module Api
  module V1
    class EventTripsController < Api::V1::ApplicationController
      actions :index, :show

      api :GET, '/v1/event_trips', 'Get event trips list for store'
      param_group :store_api_key, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/event_trips

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
      }

      ########### Response Example ################
      {
        "event_trips":[
          {
            "id": 1,
            "name": "Double Dive",
            "cost": 99,
            "commission_rate_money": 9,
            "exclude_tariff_rates": false,
            "local_cost": 10,
            "tax_rate":
              {
                "id": 238,
                "amount": 0.0
              },
            "commission_rate":
              {
                "id": 52,
                "amount": 0.0
              }
          }
        ]
      }
      '
      def index
        super
      end

      api :GET, '/v1/event_trips/:id', 'Get event trip details information'
      param_group :store_api_key, Api::V1::ApplicationController
      param :id, Integer, desc: 'Event Trip ID', required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/event_trips/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
      }

      ########### Response Example ################
      {
        "event_trip":
          {
            "id": 1,
            "name": "Double Dive",
            "cost": 99,
            "commission_rate_money": null,
            "exclude_tariff_rates": false,
            "local_cost": null,
            "tax_rate":
              {
                "id": 238,
                "amount": 0.0
              },
            "commission_rate":
              {
                "id": 52,
                "amount": 0.0
              }
          }
      }
      '
      def show
        super
      end

      protected
      def begin_of_association_chain
        current_store
      end

      def collection
        @event_trips ||= end_of_association_chain.with_cost
      end
    end
  end
end
