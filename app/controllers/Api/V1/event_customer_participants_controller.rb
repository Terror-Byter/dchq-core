module Api
  module V1
    class EventCustomerParticipantsController < Api::V1::ApplicationController
      belongs_to :event
      actions :create, :update, :destroy

      api :POST, '/v1/events/:event_id/event_customer_participants', 'Create event customer participant'
      formats [:json]
      def create
        super
      end

      api :PUT, '/v1/events/:event_id/event_customer_participants/:id', 'Update event customer participant'
      formats [:json]
      def update
        super
      end

      api :DELETE, '/v1/events/:event_id/event_customer_participants/:id', 'Delete event customer participant'
      formats [:json]
      def destroy
        super
      end
    end
  end
end
