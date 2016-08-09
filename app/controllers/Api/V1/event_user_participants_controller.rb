module Api
  module V1
    class EventUserParticipantsController < Api::V1::ApplicationController
      belongs_to :event
      actions :create, :update, :destroy

      before_filter :detect_event, :available?
      before_filter :check_event_for_cancel, only: [:update]

      def_param_group :required_param do
        param :event_id, Integer, desc: 'Event ID', required: true
      end

      def_param_group :create do
        param :event_user_participant, Hash, required: true, action_aware: true do
          param :role, String, desc: 'Staff Member role in event', required: true
          param :user_id, Integer, desc: 'User ID which you want add to event', required: true
        end
      end

      api :POST, '/v1/events/:event_id/event_user_participants', 'Add staff member to event'
      param_group :store_api_key, Api::V1::ApplicationController
      param_group :required_param
      param_group :create
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/events/12/event_user_participants

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
        event_id: 12,
        event_user_participant:
          {
            user_id: 1,
            role: "Diver"
          }
      }
      ########### Response Example ################
      # SUCCESS
      no content

      # FAILURE
      {
        "event_id": [
          "can\'t be blank"
        ],
        "user_id": [
          "can\'t be blank"
        ],
        "role": [
          "can\'t be blank"
        ]
      }
      '
      def create
        super
      end

      api :PUT, '/v1/events/:event_id/event_user_participants/:id', 'Update staff member in event'
      param :id, Integer, desc: 'Event User Participant ID', required: true
      param_group :store_api_key, Api::V1::ApplicationController
      param_group :required_param
      param_group :create
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/events/12/event_user_participants/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
        event_id: 12,
        id: 1,
        event_user_participant:
          {
            user_id: 1,
            role: "Diver"
          }
      }
      ########### Response Example ################
      # SUCCESS
      no content

      # FAILURE
      {
        "event_id": [
          "can\'t be blank"
        ],
        "user_id": [
          "can\'t be blank"
        ],
        "role": [
          "can\'t be blank"
        ]
      }
      '
      def update
        super
      end

      api :DELETE, '/v1/events/:event_id/event_user_participants/:id', 'Delete Staff Member in event'
      param :id, Integer, desc: 'Staff Member ID in event', required: true
      param :event_id, Integer, desc: 'Event ID', required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/events/1/event_user_participants/12

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
        event_id: 1,
        id: 12
      }

      ########### Response Example ################
      # SUCCESS
      no content

      # FAILURE
      errors like in method Create or Update
      '
      def destroy
        super
      end

      private
      def check_event_for_cancel
        raise EventIsCancel if @event.cancel?
      end

      def available?
        raise EventNotAvailable unless @event.can_change?
      end
    end
  end
end
