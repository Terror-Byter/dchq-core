module Api
  module V1
    class EventsController < Api::V1::ApplicationController
      actions :all, only: [:index, :show]

      api :GET, '/v1/events', "Show list of all events in the specific store"
      param :period, ['day', 'week', 'month', 'quarter', 'year'], desc: "Period for events select. By default day"
      param :starts_at, DateTime, desc: 'Start at time for event select. If period is empty'
      param :ends_at, DateTime, desc: 'Ends at time for event select. If period is empty'
      param_group :store_api_key, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/events

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
        param: "Day"

        #========= OR ==========

        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
        starts_at: "2014-08-01 09:12:59",
        ends_at: "2014-08-05"
      }

      ########### Response Example ################
      {
        "events": [
          {
            "id": 13481,
            "name": "Salida Vapor",
            "starts_at": "2014-08-06T18:00:00+12:00",
            "ends_at": "2014-08-06T21:00:00+12:00",
            "number_of_dives": 0,
            "limit_of_registrations": 15,
            "number_of_event_customer_participants": 0,
            "number_of_staff_members": 0,
            "type": "Trip",
            "price": "NZ$0.00"
          },
          {
            "id": 13482,
            "name": "Salida Costa grupo Jordi",
            "starts_at": "2014-08-09T08:30:00+12:00",
            "ends_at": "2014-08-09T17:00:00+12:00",
            "number_of_dives": 10,
            "limit_of_registrations": 15,
            "number_of_event_customer_participants": 0,
            "number_of_staff_members": 0,
            "type": "Course",
            "price": "NZ$12.00"
          }
        ]
      }
      '
      def index
        starts_at = DateTime.parse(params[:starts_at]) rescue nil
        ends_at   = DateTime.parse(params[:ends_at]) rescue nil
        @events = if starts_at && ends_at
                    collection.time_period(starts_at, ends_at)
                  else
                    period = params[:period]
                    collection.events_time(period)
                  end
      end

      api :GET, '/v1/events/:id', "Show event details"
      param_group :store_api_key, Api::V1::ApplicationController
      param :id, Integer, desc: "Event ID", required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/events/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
        id: 1
      }

      ########### Response Example ################
      {
        "event":
          {
            "id": 13465,
            "name": "daily dive trip",
            "location": "various",
            "starts_at": "2013-04-26T07:30:00Z",
            "ends_at": "2013-04-26T12:30:00Z",
            "limit_of_registrations": 15,
            "number_of_dives": 2,
            "additional_equipment": "No",
            "notes": "check for stage bottles",
            "price": "NZ$0.00",
            "boat":
              {
                "id": 23,
                "name": "Green Eyed Lady"
              },
            "event_user_participants": [
              {
                "role": "dm",
                "id": 1827,
                "full_name": "Andr\u00e9 T",
                "avatar": "https://s3.amazonaws.com/dchq_v2/user/311/original/images.jpeg?1359114579",
                "event_customer_participants": [
                  {
                    "customer_id": 3842,
                    "full_name": "Adrian Higgins"
                  }
                ]
              },
              {
                "role": "Instructor",
                "id": 1837,
                "full_name": "Vitaliy S",
                "avatar": "/assets/missing/user/original.gif",
                "event_customer_participants": [
                ]
              }
            ],
            "event_customer_participants": [
              {
                "id": 2970,
                "full_name": "Adrian Higgins",
                "bcd": " (Rent)",
                "fins": " (Rent)",
                "wetsuit": "4 (Rent)"
              }
            ]
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
    end
  end
end
