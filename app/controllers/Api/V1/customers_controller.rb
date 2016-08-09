module Api
  module V1
    class CustomersController < Api::V1::ApplicationController
      actions :all, except: [:new, :edit]

      api :GET, '/v1/customers', "Show list customers"
      param_group :user_token, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/customers

      # Request Body
      {
        user_token: <USER_TOKEN>
      }

      ########### Response Example ################
      {
        "customers": [
          {
            "id": 46114,
            "given_name": "Kelly",
            "family_name": "Barr",
            "born_on": null,
            "gender": "male",
            "email": "kellyandglennritchie@gmail.com",
            "send_event_related_emails": true,
            "telephone": "",
            "mobile_phone": "",
            "source": "",
            "default_discount_level": "0.0",
            "tax_id": "",
            "zero_tax_rate": false,
            "tag_list": [],
            "emergency_contact_details": "-",
            "hotel_name": "",
            "room_number": "",
            "customer_experience_level_id": null,
            "last_dive_on": null,
            "number_of_logged_dives": 0,
            "fins": "",
            "bcd": "",
            "wetsuit": "",
            "weight": "",
            "company": {
              "id": 597,
              "name": "Underwater Odyssey"
            },
            "address": {
              "id": 52194,
              "first": "",
              "second": "",
              "city": "",
              "state": "",
              "country_code": "",
              "post_code": ""
            },
            "custom_fields": [
              {
                id: 1,
                name: "Field Name"
                value: "Field Value"
              }
            ]
          },
          {
            "id": 46115,
            "given_name": "Tim",
            "family_name": "Hill",
            "born_on": null,
            "gender": null,
            "email": null,
            "send_event_related_emails": true,
            "telephone": null,
            "mobile_phone": null,
            "source": null,
            "default_discount_level": "0.0",
            "tax_id": null,
            "zero_tax_rate": false,
            "tag_list": [],
            "emergency_contact_details": "-",
            "hotel_name": null,
            "room_number": null,
            "customer_experience_level_id": null,
            "last_dive_on": null,
            "number_of_logged_dives": 0,
            "fins": null,
            "bcd": null,
            "wetsuit": null,
            "weight": null,
            "company": {
              "id": 597,
              "name": "Underwater Odyssey"
            },
            "address": {
              "id": 52195,
              "first": null,
              "second": null,
              "city": null,
              "state": null,
              "country_code": null,
              "post_code": null
            },
            "custom_fields": []
          }
        ]
      }'
      def index
        super
      end

      api :GET, '/v1/customers/:id', "Show customer details info"
      param :id, Integer, desc: "Customer ID", required: true
      param_group :user_token, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example  ################
      # URL
      https://app.divecentrehq.com/api/v1/customers/1

      # Request Body
      {
        user_token: <USER_TOKEN>
      }

      ########### Response Example ################
      {
      "customer":
        {
          "id": 23575,
          "given_name": "Adam",
          "family_name": "Charney",
          "email": "email@example.com",
          "telephone": "443-253-1188",
          "source": "Email",
          "credit_note": "1.0",
          "born_on": "1992-12-12",
          "last_dive_on": "2013-01-01",
          "default_discount_level": "4.0",
          "mobile_phone": "1111-111-1111-111",
          "address":
            {
              "first": "432 Some Street,",
              "second": "",
              "city": "Sydney",
              "state": "New South Wales",
              "post_code": "2111",
              "country": "Australia"
            },
          "certification_level_memberships": [
            {
              "id": 4673,
              "membership_number": "12312312",
              "certification_date": "2013-04-16",
              "primary": true,
              "certification_level":
                {
                  "id": 205,
                  "name": "Open Water Diver",
                  "certification_agency":
                    {
                      "id": 1,
                      "name": "PADI"
                    }
                  }
                }
          ],
          "bcd": " (Rent)",
          "fins": " (Rent)",
          "wetsuit": "4 (Rent)",
          "regulator": "(Rent)",
          "mask":"(Rent)",
          "sales": [
            {
              "id": 1568,
              "created_at": "2013-02-23T10:30:19-05:00",
              "grand_total": "856.9",
              "products": "OCTO ABYSS, ABYSS 22"
            },
            {
              "id": 1596,
              "created_at": "2013-03-05T13:43:58-05:00",
              "grand_total": "-252.28",
              "products": "OCTO ABYSS"
            }
          ]
        }
      }'
      def show
        super
      end

      def_param_group :create do
        param_group :user_token, Api::V1::ApplicationController
        param :customer, Hash, required: true, action_aware: true do
          param :given_name, String, desc: "Given name of the customer", required: true
          param :family_name, String, desc: "Family name of the customer", required: true
          param :born_on, Date, desc: "Date of birthday"
          param :gender, ['male', 'female'], desc: "Gender of the customer."
          param :email, String, desc: "Email of the customer"
          param :send_event_related_emails, [true, false], desc: 'Send event related emails', required: true
          param :telephone, String, desc: "Telephone of the customer"
          param :mobile_phone, String, desc: "Mobile Telephone"
          param :source, String, desc: "Customer source"
          param :default_discount_level, Integer, desc: 'Customer default discount level'
          param :tax_id, Integer, desc: 'Customer tax id'
          param :zero_tax_rate, [true, false], desc: 'Customer zero tax rate', required: true
          param :tag_list, String, desc: 'Customer tags'
          param :emergency_contact_details, String, desc: "Emergancy Contact of the customer"
          param :address, Hash, action_aware: true do
            param :first, String, desc: 'First street'
            param :second, String, desc: 'Second street'
            param :city, String, desc: 'City'
            param :state, String, desc: 'State'
            param :country_code, String, desc: 'Country in ISO'
            param :post_code, String, desc: 'Post code'
          end
          param :hotel_name, String, desc: 'Customer hotel name'
          param :room_number, String, desc: 'Customer room number in hotel'
          param :customer_experience_level_id, Integer, desc: 'Customer experience level id'
          param :last_dive_on, Date, desc: 'Last dive on date'
          param :number_of_logged_dives, Integer, desc: 'Number of logged dives'
          param :fins, %w[Jr 4/5 6/7 8/9 10/11 12/13 14/15], desc: 'Fins size'
          param :bcd, %w[Jr Xs S M L XL], desc: 'BCD size'
          param :wetsuit, String, desc: 'Wetsuit size'
          param :weight, Integer, desc: 'Customer weight'
          param :custom_fields_attributes, Hash, action_aware: true do
            param :name, String, desc: 'Custom field name'
            param :value, String, desc: 'Custom field value'
            param :_destroy, [true, false], desc: 'If true then we will remove current custom field'
          end
        end
      end

      api :POST, "/v1/customers", "Create new customer"
      param_group :create
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/customers

      # Request Body
      {
        user_token: <USER_TOKEN>,
        customer: {
          given_name: "asdas",
          family_name: "sadas",
          born_on: "1986-11-12",
          gender: "male",
          email: "kaktusyaka@gmail.com",
          send_event_related_emails: 1,
          telephone: "+3126127361278",
          mobile_phone: "+2323123123",
          source: "Source",
          default_discount_level: 10.0,
          tax_id: 12,
          zero_tax_rate: 0,
          tag_list: "",
          emergency_contact_details: "No Contact",
          address_attributes: {
            first: "1 Street",
            second: "",
            city: "New York",
            state: "Alabama",
            country_code: "US",
            post_code: "9875"
          },
          hotel_name: "First Hotel",
          room_number: "2c",
          customer_experience_level_id: "",
          last_dive_on: "2014-01-22",
          number_of_logged_dives: 0,
          fins: "M",
          bcd: "XL",
          wetsuit: "XL",
          weight: "120",
          custom_fields_attributes: {
            <RANDOM NUMBER>: {
              name: "custom field",
              value: "custom_field_value",
              _destroy: false
            },
            <RANDOM NUMBER>: {
              name: "custom field 2",
              value: "custom field value",
              _destroy: false
            }
          }
        }
      }
      ########### Response Example ################
      # SUCCESS
      no response

      #FAILURE
      {
        "company": [
          "does not exist"
        ],
        "company_id": [
          "does not exist"
        ],
        "given_name": [
          "can\'t be blank"
        ],
        "family_name": [
          "can\'t be blank"
        ]
      }
      '
      def create
        super
      end

      api :PUT, "/v1/customer/:id", "Update exist customer"
      param :id, Integer, desc: "Customer ID", required: true
      param_group :create
      formats [:json]
      example '
      ########### Request Example ################
      # URL
      https://app.divecentrehq.com/api/v1/customers/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        id: 1,
        customer: {
          given_name: "asdas",
          family_name: "sadas",
          born_on: "1986-11-12",
          gender: "male",
          email: "kaktusyaka@gmail.com",
          send_event_related_emails: 1,
          telephone: "+3126127361278",
          mobile_phone: "+2323123123",
          source: "Source",
          default_discount_level: 10.0,
          tax_id: 12,
          zero_tax_rate: 0,
          tag_list: "",
          emergency_contact_details: "No Contact",
          address_attributes: {
            first: "1 Street",
            second: "",
            city: "New York",
            state: "Alabama",
            country_code: "US",
            post_code: "9875"
          },
          hotel_name: "First Hotel",
          room_number: "2c",
          customer_experience_level_id: "",
          last_dive_on: "2014-01-22",
          number_of_logged_dives: 0,
          fins: "M",
          bcd: "XL",
          wetsuit: "XL",
          weight: "120",
          custom_fields_attributes: {
            <RANDOM NUMBER>: {
              name: "custom field",
              value: "custom_field_value",
              _destroy: false
            },
            <RANDOM NUMBER>: {
              name: "custom field 2",
              value: "custom field value",
              _destroy: false
            }
          }
        }
      }
      ########### Response Example ################
      # SUCCESS
      no content

      # FAILURE
      {
        "company": [
          "does not exist"
        ],
        "company_id": [
          "does not exist"
        ],
        "given_name": [
          "can\'t be blank"
        ],
        "family_name": [
          "can\'t be blank"
        ]
      }
      '
      def update
        params[:customer].delete(:avatar_attributes) if params[:customer][:avatar_attributes] and params[:customer][:avatar_attributes]['image'].blank?
        super
      end

      api :DELETE, '/v1/customers/:id', "Delete customer"
      param :id, Integer, desc: 'Customer ID', required: true
      param_group :user_token, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://api.divecentrehq.com/api/v1/customers/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        id: 1
      }

      ########### Response Example ################
      no content
      '
      def destroy
        super
      end

      protected
      def begin_of_association_chain
        current_company
      end
    end
  end
end
