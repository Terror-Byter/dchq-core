require 'spec_helper'

describe Api::V1::CategoriesController do
  render_views

  let(:user){ create(:user) }
  let(:company){ user.company }
  let(:store){ company.stores.first }

  context '#index' do
    before { create_list( :category, 5, store: store ) }

    context 'unauthorised' do
      before { get :index, format: :json }

      it { expect(response.status).to eq 401 }
    end

    context 'authorised' do
      before { get :index, user_token: user.authentication_token, store_api_key: store.public_key, format: :json }

      it { expect(response.status).to eq 200 }
      it { expect(JSON.parse(response.body)).to include('categories') }
      it { expect(JSON.parse(response.body)['categories']).to_not be_blank }
      it { expect(JSON.parse(response.body)['categories'][0]).to include('id') }
      it { expect(JSON.parse(response.body)['categories'][0]).to include('name') }
      it { expect(JSON.parse(response.body)['categories'][0]).to include('description') }
      it { expect(JSON.parse(response.body)['categories'][0]).to include('created_at') }
      it { expect(JSON.parse(response.body)['categories'][0]).to include('updated_at') }
    end
  end

  context '#show' do
    let(:brand) { create(:brand, store: store) }
    let(:category){ create(:category, store: store) }
    let(:supplier){ create(:supplier, company: company) }
    let(:tax_rate){ store.tax_rates.first }
    let(:commission_rate){ store.commission_rates.first }


    context 'unauthorised' do
      before {
        create( :product, store: store,
                          tax_rate: tax_rate,
                          commission_rate: commission_rate,
                          category: category,
                          brand: brand,
                          supplier: supplier)

        get :show, id: category.id, format: :json
      }

      it { expect(response.status).to eq 401 }
    end

    context 'authorised' do
      before {
        create( :product, store: store,
                          tax_rate: tax_rate,
                          commission_rate: commission_rate,
                          category: category,
                          brand: brand,
                          supplier: supplier)
        get :show, user_token: user.authentication_token, store_api_key: store.public_key, id: category.id, format: :json
      }

      it { expect(response.status).to eq 200 }
      it { expect(JSON.parse(response.body)).to include('category') }
      it { expect(JSON.parse(response.body)['category']).to_not be_blank }
      it { expect(JSON.parse(response.body)['category']).to include('id') }
      it { expect(JSON.parse(response.body)['category']).to include('name') }
      it { expect(JSON.parse(response.body)['category']).to include('description') }
      it { expect(JSON.parse(response.body)['category']).to include('created_at') }
      it { expect(JSON.parse(response.body)['category']).to include('updated_at') }
      it { expect(JSON.parse(response.body)['category']).to include('units_in_stock') }
      it { expect(JSON.parse(response.body)['category']).to include('stock_value') }
      it { expect(JSON.parse(response.body)['category']).to include('avg_monthly_sale') }
      it { expect(JSON.parse(response.body)['category']).to include('last_sale') }
      it { expect(JSON.parse(response.body)['category']['products']).to_not be_blank }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('id') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('accounting_code') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('archived') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('barcode') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('commission_rate_money') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('description') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('low_inventory_reminder') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('markup') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('name') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('number_in_stock') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('offer_price') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('retail_price') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('sent_at') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('sku_code') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('supplier_code') }
      it { expect(JSON.parse(response.body)['category']['products'][0]).to include('supply_price') }
    end
  end
end
