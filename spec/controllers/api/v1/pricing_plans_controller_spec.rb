require 'spec_helper'

describe Api::V1::PricingPlansController do
  render_views
  let(:pricing_plan){ create(:pricing_plan) }

  before { pricing_plan }

  context '#index' do
    before { get :index, format: :json }

    it { expect(response.status).to eq 200 }
    it { expect(JSON.parse(response.body)).to include('pricing_plans') }
    it { expect(JSON.parse(response.body)['pricing_plans']).to_not be_blank }
    it { expect(JSON.parse(response.body)['pricing_plans'][0]).to include('billing_period') }
    it { expect(JSON.parse(response.body)['pricing_plans'][0]).to include('description') }
    it { expect(JSON.parse(response.body)['pricing_plans'][0]).to include('id') }
    it { expect(JSON.parse(response.body)['pricing_plans'][0]).to include('name') }
    it { expect(JSON.parse(response.body)['pricing_plans'][0]).to include('number_of_customers') }
    it { expect(JSON.parse(response.body)['pricing_plans'][0]).to include('number_of_shops') }
    it { expect(JSON.parse(response.body)['pricing_plans'][0]).to include('number_of_users') }
    it { expect(JSON.parse(response.body)['pricing_plans'][0]).to include('price') }
  end
end
