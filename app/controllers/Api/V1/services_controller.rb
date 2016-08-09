module Api
  module V1
    class ServicesController < Api::V1::ApplicationController
      before_filter :check_store_service_settings

      protected
      def begin_of_association_chain
        current_store
      end

      def build_resource
        super.tap do |attr|
          attr.store = current_store
          attr.booked_in = Date.today
        end
      end

      def collection
        @services ||= case params[:filter]
                      when nil, 'all' then end_of_association_chain
                      else end_of_association_chain.send(params[:filter])
                      end
      end
      def check_store_service_settings
        raise NoAccessToServices unless current_store.has_service_settings?
      end
    end
  end
end
