module Api
  module V1
    class CourseEventsController < Api::V1::ApplicationController
      actions :update, :create, :destroy

      def_param_group :create do
        param_group :store_api_key, Api::V1::ApplicationController
        param :course_event, Hash, required: true, action_aware: true do
          param :certification_level_id, Integer, desc: 'Certification Level ID', required: true
          param :limit_of_registrations, Integer, desc: 'Limit for registered people in course'
          param :starts_at, DateTime, desc: 'Course day 1 start date and time', required: true
          param :ends_at, DateTime, desc: 'Course day 1 end date and time', required: true
          param :boat_id, Integer, desc: 'Boat ID'
          param :number_of_dives, Integer, desc: 'Number of dives for course for day 1'
          param :additional_equipment, String, desc: 'Additional Equipment for day 1'
          param :location, String, desc: 'Additional Equipment for day 1'
          param :children_attributes, Hash, required: false, action_aware: true do
            param :'new_{random_number}', Hash, action_aware: true do
              param :starts_at, DateTime, desc: 'Course day 2 start date and time', required: true
              param :ends_at, DateTime, desc: 'Course day 2 end date and time', required: true
              param :boat_id, Integer, desc: 'Boat ID'
              param :number_of_dives, Integer, desc: 'Number of dives for course for day 2'
              param :location, String, desc: 'Additional Equipment for day 2'
              param :additional_equipment, String, desc: 'Additional Equipment for day 2'
              param :_destroy, [true, false], desc: 'Should be false', required: true
            end
            param :'new_{random_number}', Hash, action_aware: true do
              param :starts_at, DateTime, desc: 'Course day 3 start date and time', required: true
              param :ends_at, DateTime, desc: 'Course day 3 end date and time', required: true
              param :boat_id, Integer, desc: 'Boat ID'
              param :number_of_dives, Integer, desc: 'Number of dives for course for day 3'
              param :location, String, desc: 'Additional Equipment for day 3'
              param :additional_equipment, String, desc: 'Additional Equipment for day 3'
              param :_destroy, [true, false], desc: 'Should be false', required: false
            end
          end
        end
      end

      api :POST, '/v1/course_events', 'Create new course'
      param_group :create
      formats [:json]
      example '
      #URL
      https://app.divecentrehq.com/api/v1/course_events

      #Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
        course_event: {
          certification_level_id: 205,
          limit_of_registrations: 21,
          starts_at: "03-07-2013 06:00",
          ends_at: "03-07-2013 07:00",
          boat_id: 1,
          number_of_dives: 12,
          location: "location",
          additional_equipment: "additioan equipment",
          children_attributes: {
            new_1372762355313: {
              starts_at: "04-07-2013 08:00",
              ends_at: "04-07-2013 09:00",
              boat_id: 2,
              number_of_dives: 12,
              location: "location day 2",
              additional_equipment: "additional equipment day 2",
              _destroy: false
            }
          },
          instructions: "instruction",
          notes: "some notes",
          private: false,
          enable_booking: true,
          price: 320
      }
      ######### Response Example ################
      #SUCCESS
      no content

      FAILURE
      {
        starts_at: [
          "can\'t be blank",
          "is not a valid datetime"
        ],
        ends_at: [
          "can\'t be blank",
          "is not a valid datetime"
        ]
      }
      '
      def create
        super
      end

      api :PUT, '/v1/course_events/:id', 'Update exist course event'
      param :id, Integer, desc: 'Course Event PARENT ID', required: true
      param_group :create
      formats [:json]
      example '
      #URL
      https://app.divecentrehq.com/api/v1/course_events/1

      #Request Body
      {
        id: 1,
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
        course_event: {
          certification_level_id: 205,
          limit_of_registrations: 21,
          starts_at: "03-07-2013 06:00",
          ends_at: "03-07-2013 07:00",
          boat_id: 1,
          number_of_dives: 12,
          location: "location",
          additional_equipment: "additioan equipment",
          children_attributes: {
            0: {
              starts_at: "04-07-2013 08:00",
              ends_at: "04-07-2013 09:00",
              boat_id: 1,
              number_of_dives: 12,
              location: "location day 2",
              additional_equipment: "additional equipment day 2",
              _destroy: 1, #if you want destroy course day
              id: 14145
            }
          },
          instructions: "instruction",
          notes: "some notes",
          private: false,
          enable_booking: true,
          price: 320.0
        }
      }
      ######### Response Example ################
      #SUCCESS
      no content

      #FAILURE
      {
        starts_at: [
          "can\'t be blank",
          "is not a valid datetime"
        ],
        ends_at: [
          "can\'t be blank",
          "is not a valid datetime"
        ]
      }
      '
      def update
        super
      end

      api :DELETE, '/v1/course_events/:id', 'Delete course event'
      param_group :store_api_key, Api::V1::ApplicationController
      param :id, Integer, desc: 'Course Event ID', required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/course_events/1

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
