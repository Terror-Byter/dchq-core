module Api
  module V1
    class UsersController < Api::V1::ApplicationController
      actions :index
      custom_actions collection: [:info]

      api :GET, '/v1/users', 'List of all users for specific dive centre'
      param_group :user_token, Api::V1::ApplicationController
      formats [:json]
      description 'This method allow only for manager\'s user'
      example '
      ########### Request Example ################
      # URL
      https://app.divecentrehq.com/api/v1/users/1

      # Request Body
      {
        user_token: <USER_TOKEN>
      }

      # Response
      {
        "users": [
          {
            "id": 311,
            "email": "demo+1@divecentrehq.com",
            "given_name": "Andr\u00e9",
            "family_name": "T",
            "alternative_email": "",
            "phone": "02-4567-8901",
            "emergency_contact_details": "Julie Smith, +64 22-345-6789"
            "address":
              {
                "first": "123 Pitt Street",
                "second": "",
                "city": "Sydney",
                "state": "NSW",
                "post_code": "2011",
                "country": "United States"
              }
          }
        ]
      }
      '
      def index
        raise NoAccess unless current_user.try(:manager?)
        super
      end

      api :GET, '/v1/users/info', 'Details information about your user'
      param_group :user_token, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example ################
      # URL
      https://app.divecentrehq.com/api/v1/users/info

      # Request Body
      {
        user_token: <USER_TOKEN>
      }

      # Response
      {
        "user":
          {
            "id": 311,
            "email": "demo+1@divecentrehq.com",
            "time_zone": "Auckland",
            "role": "manager",
            "created_at": "2012-02-02T12:34:49Z",
            "updated_at": "2013-05-08T08:15:21Z",
            "avatar": <AVATAR_URL>,
            "company":
              {
                "id": 185,
                "name": "Andre"
              },
            "given_name": "Andr\u00e9",
            "family_name": "T",
            "alternative_email": "",
            "phone": "02-4567-8901",
            "emergency_contact_details": "Julie Smith, +64 22-345-6789",
            "available_days":
              {
                "monday": "1",
                "tuesday": "1",
                "wednesday": "0",
                "thursday": "1",
                "friday": "1",
                "saturday": "1",
                "sunday": "0"
              },
            "start_date": null,
            "end_date": null,
            "contracted_hours": "35",
            "mailchimp_api_key": "68b0412a51db3d914eff7771bb6f03cb-us6",
            "mailchimp_list_id_for_customer": null,
            "mailchimp_list_id_for_staff_member": null,
            "mailchimp_list_id_for_business_contact": null,
            "locale": "en",
            "address":
              {
                "first": "123 Pitt Street",
                "second": "",
                "city": "Sydney",
                "state": "NSW",
                "post_code": "2011",
                "country":null
              }
          }
      }
      '
      def info
        @user = current_user
      end

      private
      def begin_of_association_chain
        current_company
      end
    end
  end
end
