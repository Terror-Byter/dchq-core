module Api
  module V1
    class OtherEventsController < Api::V1::ApplicationController
      actions :update, :create, :destroy

      def_param_group :create do
        param_group :store_api_key, Api::V1::ApplicationController
        param :other_event, Hash, required: true, action_aware: true do
          param :starts_at, DateTime, desc: 'Event start date and time', required: true
          param :ends_at, DateTime, desc: 'Event end date and time', required: true
          param :event_type_id, Integer, desc: 'Event Type ID', required: true
          param :boat_id, Integer, desc: 'Boat ID'
          param :limit_of_registrations, Integer, desc: 'Limit of registrations for event'
          param :location, String, desc: 'Event location'
          param :number_of_dives, Integer, desc: 'Number of dives for event'
          param :frequency, %w(One-off Daily Weekly Fortnightly Monthly Yearly), desc: "Frequency.", required: true
          param :number_of_frequency, Integer, desc: "Number of frequency. This param is REQUIRED if FREQUENCY NOT EQUAL 'One-off'"
        end
      end

      api :POST, '/v1/other_events', 'Create new event'
      param_group :create
      param :event_trip_id, Integer, desc: 'This param REQUIRED ONLY IF EVENT_TYPE EQUAL "Dive Trip"'
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/events

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
        other_event: {
          starts_at: "2013-04-30 9:35:40",
          ends_at: "2013-04-30 10:35:40",
          event_type_id: 1, #Selected Dive Trip
          event_trip_id: 12,
          boat_id: 1,
          limit_of_registrations: 10,
          location: "Island",
          number_of_dives: 0,
          frequency: "Daily",
          number_of_frequency: 10
        }
      }

      ########### Response Example ################
      # SUCCESS
      no content

      # FAILURE
      {
        "starts_at": [
          "can\'t be blank",
          "is not a valid datetime"
        ],
        "ends_at": [
          "can\'t be blank",
          "is not a valid datetime"
        ],
        "event_type": [
          "can\'t be blank"
        ]
      }
      '
      def create
        super
      end

      api :PUT, '/v1/other_events/:id', 'Update event'
      param :id, Integer, desc: 'Other Event ID', required: true
      param_group :create
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/other_events/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
        id: 1,
        other_event: {
          starts_at: "2013-04-30 9:35:40",
          ends_at: "2013-04-30 10:35:40",
          event_type_id: 1, #Selected Dive Trip
          event_trip_id: 12,
          boat_id: 1,
          limit_of_registrations: 10,
          location: "Island",
          number_of_dives: 0,
          frequency: "Daily",
          number_of_frequency: 10
        }
      }

      ########### Response Example ################
      # SUCCESS
      no content

      # FAILURE
      {
        "starts_at": [
          "can\'t be blank",
          "is not a valid datetime"
        ],
        "ends_at": [
          "can\'t be blank",
          "is not a valid datetime"
        ],
        "event_type": [
          "can\'t be blank"
        ]
      }
      '
      def update
        super
      end

      api :DELETE, '/v1/other_events/:id', 'Delete event'
      param_group :store_api_key, Api::V1::ApplicationController
      param :id, Integer, desc: 'Other Event ID', required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/other_events/1

      # Request Body
      {
        id: 1,
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
      }

      ########### Response Example ################
      no content
      '
      def destroy
        super
      end

      protected
      def begin_of_association_chain
        current_store
      end
    end
  end
end
