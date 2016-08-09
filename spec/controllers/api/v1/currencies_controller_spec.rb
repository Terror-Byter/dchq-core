require 'spec_helper'

describe Api::V1::CurrenciesController do
  render_views
  let(:currency){ create(:currency) }

  before {
    currency
  }

  context '#index' do
    context 'authorized' do
      before {
        get :index, format: :json
      }

      it { expect(response.status).to eq 200 }
      it { expect(JSON.parse(response.body)).to include('currencies') }
      it { expect(JSON.parse(response.body)['currencies']).to_not be_blank }
      it { expect(JSON.parse(response.body)['currencies'][0]).to include('code') }
      it { expect(JSON.parse(response.body)['currencies'][0]).to include('created_at') }
      it { expect(JSON.parse(response.body)['currencies'][0]).to include('delimiter') }
      it { expect(JSON.parse(response.body)['currencies'][0]).to include('format') }
      it { expect(JSON.parse(response.body)['currencies'][0]).to include('id') }
      it { expect(JSON.parse(response.body)['currencies'][0]).to include('name') }
      it { expect(JSON.parse(response.body)['currencies'][0]).to include('precision') }
      it { expect(JSON.parse(response.body)['currencies'][0]).to include('separator') }
      it { expect(JSON.parse(response.body)['currencies'][0]).to include('unit') }
      it { expect(JSON.parse(response.body)['currencies'][0]).to include('updated_at') }
    end
  end
end
