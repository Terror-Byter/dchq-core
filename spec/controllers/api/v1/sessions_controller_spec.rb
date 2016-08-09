require 'spec_helper'

describe Api::V1::SessionsController do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let(:user){ create(:user, email: 'email@gmail.com', password: 'testing1', password_confirmation: 'testing1') }

  context '#create' do
    context 'user and password is correct' do
      before do
        user
        post :create, user: { email: 'email@gmail.com', password: 'testing1' }, format: :json
      end

      it { expect(response.status).to eq 200 }
      it { expect(JSON.parse(response.body)['success']).to be_truthy }
      it { expect(JSON.parse(response.body)['info']).to eq 'Logged in' }
      it { expect(JSON.parse(response.body)['data']).to include('user_token') }
      it { expect(JSON.parse(response.body)['data']['user_token']).to eq user.authentication_token }
    end

    context 'user and password is incorrect' do
      before do
        post :create, user: { email: 'email@gmail.com', password: 'testing1' }, format: :json
      end

      it { expect(response.status).to eq 401 }
      it { expect(JSON.parse(response.body)['error']).to eq 'Invalid email or password.' }
    end
  end
end
