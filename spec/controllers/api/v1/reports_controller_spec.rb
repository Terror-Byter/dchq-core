require 'spec_helper'

describe Api::V1::ReportsController do
  let(:user){ create(:user) }
  let(:company){ user.company }
  let(:store){ company.stores.first }

  context '#sales_by_brand' do
    before { get :sales_by_brand, format: :json, user_token: user.authentication_token, store_api_key: store.public_key }

    it { expect(response.status).to eq 200 }
  end

  context '#sales_by_category' do
    before { get :sales_by_category, format: :json, user_token: user.authentication_token, store_api_key: store.public_key }

    it { expect(response.status).to eq 200 }
  end

  context '#sales_by_products' do
    before { get :sales_by_products, format: :json, user_token: user.authentication_token, store_api_key: store.public_key }

    it { expect(response.status).to eq 200 }
  end

  context '#sales_by_day' do
    before { get :sales_by_day, format: :json, user_token: user.authentication_token, store_api_key: store.public_key }

    it { expect(response.status).to eq 200 }
    it { expect(JSON.parse(response.body)).to include('sales_inc_tax') }
    it { expect(JSON.parse(response.body)).to include('taxes') }
    it { expect(JSON.parse(response.body)).to include('taxable_revenue') }
    it { expect(JSON.parse(response.body)).to include('cost_of_goods') }
    it { expect(JSON.parse(response.body)).to include('gross_profit') }
  end

  context '#sales_by_staff_member' do
    before { get :sales_by_staff_member, format: :json, user_token: user.authentication_token, store_api_key: store.public_key }

    it { expect(response.status).to eq 200 }
  end
end
