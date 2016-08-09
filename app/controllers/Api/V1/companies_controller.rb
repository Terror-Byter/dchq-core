module Api
  module V1
    class CompaniesController < Api::V1::ApplicationController
      skip_before_filter :authenticate_user_from_token!

      actions :create

      api :POST, '/v1/companies', 'Sign up new company'
      formats [:json]
      param :company, Hash, required: true, action_aware: true do
        param :name, String, desc: "Company name", required: true
        param :email, String, desc: "Company email address", required: true
        param :telephone, Integer, desc: 'Company phone', required: true
        param :currency_for_store, Integer, desc: 'Store currency id. By default store currency is USD', required: true
        param :address_attributes, Hash, action_aware: true do
          param :first, String, desc: 'First Street of dive centre address'
          param :second, String, desc: 'Second Street of dive centre address'
          param :city, String, desc: 'City name of dive centre address'
          param :state, String, desc: 'State of dive centre address'
          param :country_code, String, desc: 'Country Code Street of dive centre address. e.g uk, us, ag, etc...'
        end
      end
      param :user, Hash, required: true, action_aware: true do
        param :given_name, String, required: true, desc: 'User given name'
        param :family_name, String, required: true, desc: 'User family name'
        param :email, String, required: true, desc: 'User email address'
        param :password, String, required: true, desc: 'User password'
        param :password_confirmation, String, required: true, desc: 'User password confirmaton'
        param :time_zone, String, required: true, desc: 'User timezone'
      end
      param :store, Hash, required: true, action_aware: true do
        param :tax_rate_inclusion, [true, false], required: true, desc: 'Tax Rate Type for store. If tax rate inc then value should be true'
        param :commission_rates_attributes, Hash, action_aware: true do
          param :amount, Float, required: true, desc: 'Commission Rate value. Each store has commission rate with amount 0 by default'
        end
        param :tax_rates_attributes, Hash, action_aware: true do
          param :amount, Float, required: true, desc: 'Tax Rate value. Each store has tax rate with amount 0 by default'
          param :identifier, String, desc: "Tax Rate human name"
        end
        param :payment_methods_attributes, Hash, action_aware: true do
          param :name, String, required: true, desc: 'Name of payment method. By default each store has a few payment methods. There are Cash, Paypal, Credit Card'
        end
      end
      example '
      ########### Request Example #################
      # URL
      https:://app.divecentrehq.com/api/v1/companies

      #Request Body
      {
        company: {
          name: "Awesome Company",
          email: "company@example.com",
          telephone: "7756454564",
          currency_for_store: 1,
          address_attributes: {
            first: "17th Street",
            second: "",
            city: "Awesome City",
            state: "Awesome State",
            country_code: "uk",
            post_code: "12355"
          }
        },
        user: {
          given_name: "John",
          family_name: "Doe",
          email: "email@example.com",
          password: "[FILTERED]",
          password_confirmation: "[FILTERED]",
          time_zone: "London"
        },
        store: {
          payment_methods_attributes: {
            0: {
              name: "Cash",
            },
            1: {
              name: "Paypal",
            },
            2: {
              name: "Credit Card",
            }
          },
          tax_rate_inclusion: true ,
          tax_rates_attributes: {
            0: {
              identifier: "Tax rate 1",
              amount: 12,
            },
            1400755194464: {
              identifier: "Tax Rate 2",
              amount: 13,
            }
          },
          commission_rates_attributes: {
            0: {
              amount: 12,
            },
            1400755205266: {
              amount: 15,
            }
          }
        }
      }

      ########### Response Example ################
      #SUCCESS
      {
        success: true,
        info: "Logged in",
        data: {
          user_token: <USER_TOKEN>
          store_api_key: <STORE_API_KEY>
        }
      }

      #FAILURE
      {
        errors: {
          company: {
            users.email: ["can\'t be blank"],
            users.password: ["can\'t be blank"],
            name: ["can\'t be blank"],
            telephone: ["can\'t be blank"],
            email: ["can\'t be blank", "does not appear to be valid"]
          }
        }
      }
      '
      def create
        company = Company.new(params[:company])
        company.users.build(params[:user])
        ActiveRecord::Base.transaction do
          if company.save
            sign_in(User, company.owner)
            store = company.stores.first
            if store.update_attributes(params[:store])
              company.owner.create_avatar unless company.owner.avatar
              company.owner.create_address unless company.owner.address
              render status: 200, json: { success: true, info: "Logged in", data: { user_token: company.owner.authentication_token, store_api_key: company.stores.first.api_key } }
            else
              render status: 401, json: { errors: { store: store.errors } }
              raise ActiveRecord::Rollback
              return
            end
          else
            render status: 401, json: { errors: { company: company.errors } }
          end
        end
      end
    end
  end
end
