#require 'spec_helper'

#describe Api::V1::CustomersController do
  #render_views

  #let(:company){ create(:company) }
  #let(:user){ create(:user, company: company) }

  #context '#index' do
    #before { create_list(:customer, 5, company: company) }

    #context 'unauthorised' do
      #before { get :index, format: :json }

      #it { expect(response.status).to eq 401 }
    #end

    #context 'authorised' do
      #before { get :index, user_token: user.authentication_token, format: :json }

      #it { expect(response.status).to eq 200 }
      #it { expect(JSON.parse(response.body)).to include('customers') }
      #it { expect(JSON.parse(response.body)['customers']).to_not be_blank }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('given_name') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('family_name') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('born_on') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('gender') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('email') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('send_event_related_emails') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('telephone') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('mobile_phone') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('source') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('default_discount_level') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('tax_id') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('zero_tax_rate') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('tag_list') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('emergency_contact_details') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('company') }
      #it { expect(JSON.parse(response.body)['customers'][0]['company']).to_not be_blank }
      #it { expect(JSON.parse(response.body)['customers'][0]['company']).to include('id') }
      #it { expect(JSON.parse(response.body)['customers'][0]['company']).to include('name') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('custom_fields') }
      #it { expect(JSON.parse(response.body)['customers'][0]['custom_fields']).to_not be_blank }
      #it { expect(JSON.parse(response.body)['customers'][0]['custom_fields'][0]).to include('id') }
      #it { expect(JSON.parse(response.body)['customers'][0]['custom_fields'][0]).to include('name') }
      #it { expect(JSON.parse(response.body)['customers'][0]['custom_fields'][0]).to include('value') }
      #it { expect(JSON.parse(response.body)['customers'][0]['address']).to_not be_blank }
      #it { expect(JSON.parse(response.body)['customers'][0]['address']).to include('first') }
      #it { expect(JSON.parse(response.body)['customers'][0]['address']).to include('second') }
      #it { expect(JSON.parse(response.body)['customers'][0]['address']).to include('city') }
      #it { expect(JSON.parse(response.body)['customers'][0]['address']).to include('country_code') }
      #it { expect(JSON.parse(response.body)['customers'][0]['address']).to include('post_code') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('hotel_name') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('room_number') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('customer_experience_level_id') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('last_dive_on') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('number_of_logged_dives') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('fins') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('bcd') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('wetsuit') }
      #it { expect(JSON.parse(response.body)['customers'][0]).to include('weight') }
    #end
  #end

  #context '#create' do
    #context 'unauthorised' do
      #before { post :create, format: :json }

      #it { expect(response.status).to eq 401 }
    #end

    #context 'authorised' do
      #context 'with valid params' do
        #before {
          #post :create, user_token: user.authentication_token,
                        #customer: attributes_for(:customer),
                        #format: :json
        #}

        #it { expect(response.status).to eq 201 }
        #it { expect(Customer.count).to_not be_zero }
      #end
    #end

    #context 'with invalid params' do
      #before { post :create, user_token: user.authentication_token, format: :json }

      #it { expect(response.status).to eq 422 }
      #it { expect(JSON.parse(response.body)).to include('errors') }
      #it { expect(JSON.parse(response.body)['errors']).to_not be_blank }
    #end

  #end

  #context '#update' do
    #let(:customer){ create(:customer, company: company )}

    #context 'unauthorised' do
      #before { put :update, id: customer.id, format: :json }

      #it { expect(response.status).to eq 401 }
    #end

    #context 'authorised' do
      #context 'with valid params' do
        #before {
          #put :update, user_token: user.authentication_token,
                       #id: customer.id,
                       #product: { givem_name: Faker::Name.first_name, family_name: Faker::Name.last_name },
                       #format: :json
        #}

        #it { expect(response.status).to eq 204 }
      #end

      #context 'with invalid params' do
        #before { put :update, user_token: user.authentication_token,
                 #id: customer.id,
                 #customer: { givem_name: '', family_name: '' },
                 #format: :json }

        #it { expect(response.status).to eq 422 }
        #it { expect(JSON.parse(response.body)).to include('errors') }
        #it { expect(JSON.parse(response.body)['errors']).to_not be_blank }
      #end
    #end
  #end
#end
