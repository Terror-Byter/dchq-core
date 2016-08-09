require 'spec_helper'

describe Api::V1::CompaniesController do

  let(:currency){ create(:currency) }
  let(:pricing_plan){ create(:pricing_plan) }

  context '#create' do
    context 'with valid data' do
      before do
        post :create, format: :json,
          company: {
          name: Faker::Company.name,
          email: 'hellofriend@gmail.com',
          telephone: '123456789',
          currency_for_store: currency.id,
          pricing_plan_id: pricing_plan.id,
          address_attributes: {
            first: 'Street 1',
            second: 'Street 2',
            city: 'Moscov',
            state: 'Moscov',
            country_code: 'us'
          }
        },
        user: {
          given_name: Faker::Name.first_name,
          family_name: Faker::Name.last_name,
          email: 'supertest@gmail.com',
          password: 'testing1',
          password_confirmation: 'testing1',
          time_zone: 'London'
        },
        store: {
          tax_rate_inclusion: true,
          tax_rates_attributes: {
            '0' => {
              amount: 12,
              identifier: 'Indent'
            }
          },
          payment_methods_attributes: {
            '0' => {
              name: 'Default'
            }
          },
          commission_rates_attributes: {
            '0' => {
              amount: 10
            }
          }
        }
      end

      it{ expect(response.status).to eq 200 }
      it{ expect(JSON.parse(response.body)['success']).to be_truthy }
      it{ expect(JSON.parse(response.body)['info']).to eq 'Logged in' }
      it{ expect(JSON.parse(response.body)['data']).to include('user_token') }
      it{ expect(Company.count).to eq 1 }
    end

    context 'with valid data only for company' do
      before do
        post :create, format: :json,
          company: {
          name: Faker::Company.name,
          email: 'hellofriend@gmail.com',
          telephone: '123456789',
          currency_for_store: currency.id,
          pricing_plan_id: pricing_plan.id,
          address_attributes: {
            first: 'Street 1',
            second: 'Street 2',
            city: 'Moscov',
            state: 'Moscov',
            country_code: 'us'
          }
        },
        user: {
          given_name: Faker::Name.first_name,
          family_name: Faker::Name.last_name,
          email: 'supertest@gmail.com',
          password: 'testing1',
          password_confirmation: 'testing1',
          time_zone: 'London'
        },
        store: {
          tax_rate_inclusion: true,
          tax_rates_attributes: {
            '0' => {
              amount: 12,
              identifier: 'Indent'
            }
          },
          payment_methods_attributes: {
            '0' => {
              name: 'Default'
            }
          },
          commission_rates_attributes: {
            '0' => {
              amount: 'wrong'
            }
          }
        }
      end

      it{ expect(response.status).to eq 401 }
      it{ expect(Company.count).to eq 0 }
    end


    context 'with invalid params it should return dive errors' do
      before { post :create, format: :json }

      it{ expect(response.status).to eq 401 }
      it{ expect(Company.count).to eq 0 }
      it{ expect(JSON.parse(response.body)['errors']).to_not be_blank }
    end
  end
end
