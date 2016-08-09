require 'spec_helper'

describe Api::V1::ProductsController do
  render_views

  let(:user){ create(:user) }
  let(:company){ user.company }
  let(:store){ company.stores.first }
  let(:category){ create(:category, store: store) }
  let(:brand){ create(:brand, store: store) }
  let(:supplier){ create(:supplier, company: company) }
  let(:tax_rate){ store.tax_rates.first }
  let(:commission_rate){ store.commission_rates.first }

  context '#index' do
    before { create_list( :product, 5, store: store,
                                       tax_rate: tax_rate,
                                       commission_rate: commission_rate,
                                       category: category,
                                       brand: brand,
                                       supplier: supplier ) }

    context 'unauthorised' do
      before { get :index, format: :json }

      it { expect(response.status).to eq 401 }
    end

    context 'authorised' do
      before { get :index, user_token: user.authentication_token, store_api_key: store.public_key, format: :json }

      it { expect(response.status).to eq 200 }
      it { expect(JSON.parse(response.body)).to include('products') }
      it { expect(JSON.parse(response.body)['products']).to_not be_blank }
      it { expect(JSON.parse(response.body)['products'][0]).to include('accounting_code') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('archived') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('barcode') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('image') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('brand') }
      it { expect(JSON.parse(response.body)['products'][0]['brand']).to_not be_blank }
      it { expect(JSON.parse(response.body)['products'][0]['brand']).to include('id') }
      it { expect(JSON.parse(response.body)['products'][0]['brand']).to include('name') }
      it { expect(JSON.parse(response.body)['products'][0]['category']).to_not be_blank }
      it { expect(JSON.parse(response.body)['products'][0]['category']).to include('id') }
      it { expect(JSON.parse(response.body)['products'][0]['category']).to include('name') }
      it { expect(JSON.parse(response.body)['products'][0]['commission_rate']).to_not be_blank }
      it { expect(JSON.parse(response.body)['products'][0]['commission_rate']).to include('id') }
      it { expect(JSON.parse(response.body)['products'][0]['commission_rate']).to include('amount') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('commission_rate_money') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('description') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('id') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('low_inventory_reminder') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('markup') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('name') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('number_in_stock') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('offer_price') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('retail_price') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('sent_at') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('sku_code') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('supplier_code') }
      it { expect(JSON.parse(response.body)['products'][0]['supplier']).to_not be_blank }
      it { expect(JSON.parse(response.body)['products'][0]['supplier']).to include('id') }
      it { expect(JSON.parse(response.body)['products'][0]['supplier']).to include('name') }
      it { expect(JSON.parse(response.body)['products'][0]).to include('supply_price') }
    end
  end

  context '#show' do
    let(:product) { create(:product, store: store,
                              tax_rate: tax_rate,
                              commission_rate: commission_rate,
                              category: category,
                              brand: brand,
                              supplier: supplier) }
    context 'unauthorised' do
      before {
        product
        get :show, id: product.id, format: :json
      }

      it { expect(response.status).to eq 401 }
    end

    context 'authorised' do
      before {
        product
        get :show, user_token: user.authentication_token, store_api_key: store.public_key, id: product.id, format: :json
      }

      it { expect(response.status).to eq 200 }
      it { expect(JSON.parse(response.body)).to include('product') }
      it { expect(JSON.parse(response.body)['product']).to_not be_blank }
      it { expect(JSON.parse(response.body)['product']).to include('accounting_code') }
      it { expect(JSON.parse(response.body)['product']).to include('archived') }
      it { expect(JSON.parse(response.body)['product']).to include('image') }
      it { expect(JSON.parse(response.body)['product']).to include('barcode') }
      it { expect(JSON.parse(response.body)['product']).to include('brand') }
      it { expect(JSON.parse(response.body)['product']['brand']).to_not be_blank }
      it { expect(JSON.parse(response.body)['product']['brand']).to include('id') }
      it { expect(JSON.parse(response.body)['product']['brand']).to include('name') }
      it { expect(JSON.parse(response.body)['product']['category']).to_not be_blank }
      it { expect(JSON.parse(response.body)['product']['category']).to include('id') }
      it { expect(JSON.parse(response.body)['product']['category']).to include('name') }
      it { expect(JSON.parse(response.body)['product']['commission_rate']).to_not be_blank }
      it { expect(JSON.parse(response.body)['product']['commission_rate']).to include('id') }
      it { expect(JSON.parse(response.body)['product']['commission_rate']).to include('amount') }
      it { expect(JSON.parse(response.body)['product']).to include('commission_rate_money') }
      it { expect(JSON.parse(response.body)['product']).to include('description') }
      it { expect(JSON.parse(response.body)['product']).to include('id') }
      it { expect(JSON.parse(response.body)['product']).to include('low_inventory_reminder') }
      it { expect(JSON.parse(response.body)['product']).to include('markup') }
      it { expect(JSON.parse(response.body)['product']).to include('name') }
      it { expect(JSON.parse(response.body)['product']).to include('number_in_stock') }
      it { expect(JSON.parse(response.body)['product']).to include('offer_price') }
      it { expect(JSON.parse(response.body)['product']).to include('retail_price') }
      it { expect(JSON.parse(response.body)['product']).to include('sent_at') }
      it { expect(JSON.parse(response.body)['product']).to include('sku_code') }
      it { expect(JSON.parse(response.body)['product']).to include('supplier_code') }
      it { expect(JSON.parse(response.body)['product']['supplier']).to_not be_blank }
      it { expect(JSON.parse(response.body)['product']['supplier']).to include('id') }
      it { expect(JSON.parse(response.body)['product']['supplier']).to include('name') }
      it { expect(JSON.parse(response.body)['product']).to include('supply_price') }
    end
  end

  context '#create' do
    context 'unauthorised' do
      before { post :create, format: :json }

      it { expect(response.status).to eq 401 }
    end

    context 'authorised' do
      context 'with valid params' do
        before {
          post :create, user_token: user.authentication_token,
                        store_api_key: store.public_key,
                        product: {
                          name: Faker::Company.name,
                          sku_code: 'scu_code_1234',
                          description: Faker::Lorem.paragraph,
                          number_in_stock: 10,
                          low_inventory_reminder: 1,
                          brand_id: brand.id,
                          category_id: category.id,
                          supplier_id: supplier.id,
                          accounting_code: 'accounting_code_123',
                          supplier_code: 'supplier_code_123',
                          barcode: 'barcode_1234',
                          supply_price: 100,
                          markup: 1,
                          retail_price: 150,
                          tax_rate_id: tax_rate.id,
                          commission_rate_id: commission_rate.id
                        },
                        format: :json
        }

        it { expect(response.status).to eq 201 }
        it { expect(Product.count).to eq 1 }
      end
    end

    context 'with invalid params' do
      before {
        post :create, user_token: user.authentication_token, store_api_key: store.public_key, format: :json
      }

      it { expect(response.status).to eq 422 }
      it { expect(JSON.parse(response.body)).to include('errors') }
      it { expect(JSON.parse(response.body)['errors']).to_not be_blank }
    end
  end

  context '#update' do
    let(:product){ create(:product, store: store,
                                    tax_rate: tax_rate,
                                    commission_rate: commission_rate,
                                    category: category,
                                    brand: brand,
                                    supplier: supplier) }
    before { product }

    context 'unauthorised' do
      before { put :update, id: product.id, format: :json }

      it { expect(response.status).to eq 401 }
    end

    context 'authorised' do
      context 'with valid params' do
        before {
          put :update, user_token: user.authentication_token,
                       store_api_key: store.public_key,
                       id: product.id,
                       product: {
                         name: Faker::Company.name,
                         sku_code: 'scu_code_1234',
                         description: Faker::Lorem.paragraph,
                         number_in_stock: 10,
                         low_inventory_reminder: 1,
                         brand_id: brand.id,
                         category_id: category.id,
                         supplier_id: supplier.id,
                         accounting_code: 'accounting_code_123',
                         supplier_code: 'supplier_code_123',
                         barcode: 'barcode_1234',
                         supply_price: 100,
                         markup: 1,
                         retail_price: 150,
                         tax_rate_id: tax_rate.id,
                         commission_rate_id: commission_rate.id,
                       },
                       format: :json
        }

        it { expect(response.status).to eq 204 }
        it { expect(Product.find(product.id).sku_code).to eq 'scu_code_1234' }
      end
    end

    context 'with invalid params' do
      before {
        put :update, id: product.id, product: { name: '' }, user_token: user.authentication_token, store_api_key: store.public_key, format: :json
      }

      it { expect(response.status).to eq 422 }
      it { expect(JSON.parse(response.body)).to include('errors') }
      it { expect(JSON.parse(response.body)['errors']).to_not be_blank }
    end
  end

  context '#destroy' do
    let(:product){ create(:product, store: store,
                                    tax_rate: tax_rate,
                                    commission_rate: commission_rate,
                                    category: category,
                                    brand: brand,
                                    supplier: supplier) }
    before { product }

    context 'unauthorised' do
      before { delete :destroy, id: product.id, format: :json }

      it { expect(response.status).to eq 401 }
    end

    context 'authorised' do
      before {
        delete :destroy, user_token: user.authentication_token, store_api_key: store.public_key, id: product.id, format: :json
      }

      it { expect(response.status).to eq 204 }
      it { expect(Product.count).to be_zero }
    end
  end
end
