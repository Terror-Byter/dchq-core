class Api::V1::ProductsController < Api::V1::ApplicationController
  actions :all, except: [:new, :edit]

  api :GET, '/v1/products', 'Return list of products for store'
  param_group :store_api_key, Api::V1::ApplicationController
  param :filter, ['archived', 'unarchived'], desc: 'Return archived or unarchived products related from this param. If param is not exist then method will return unarchived products'
  param :page, Integer, desc: 'Number of page for products list. Each page has 50 products. By default method return page number 1'
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/products

  #Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>,
    page: 2,
    filter: "archived"
  }

  ########### Response Example ################
  {
    products:
      [
        {
          id: 15870,
          accounting_code: "",
          archived: false,
          barcode: "NTANKRENT",
          commission_rate_money: null,
          description: "RENTAL GEAR PER DAY",
          low_inventory_reminder: 5,
          markup: 0.0,
          name: "NITROX 80CU ALUMINUM (EAN 34 OR LESS FO2)",
          number_in_stock: 930,
          offer_price: null,
          retail_price: 17.0,
          sent_at: null,
          sku_code: "NTANKRENT",
          supplier_code: "",
          supply_price: 1.0,
          image: "/assets/missing/store_product/original.gif",
          brand: {
            id: 495,
            name: "GDC"
          },
          category: {
            id: 1333,
            name: "RENTAL"
          },
          supplier: {
            id: 655,
            name: "GDC"
          },
          commission_rate: {
            id: 426,
            amount: 0.0
          },
          tax_rate: {
            id: 607,
            amount: 7.0
          }
        },
        {
          id: 22519,
          accounting_code: "",
          archived: false,
          barcode: "DGSERV",
          commission_rate_money: null,
          description: "Dive Guide Services 1 Day",
          low_inventory_reminder: 0,
          markup: 0.0,
          name: "Dive Guide Services 1 Day",
          number_in_stock: 5,
          offer_price: null,
          retail_price: 100.0,
          sent_at: "2014-06-14T23:00:26+01:00",
          sku_code: "DGSERV",
          supplier_code: "",
          supply_price: "0.0",
          brand: {
            id: 937,
            name: "GDC"
          },
          category: {
            id: 1743,
            name: "Dive Services"
          },
          supplier: {
            id: 655,
            name: "GDC"
          },
          commission_rate: {
            id: 417,
            amount: 8.0
          },
          tax_rate: {
            id: 607,
            amount: 7.0
          }
        }
      ]
  }
  '
  def index
    super
  end

  api :GET, '/v1/products/:id', 'Return product for store'
  param_group :store_api_key, Api::V1::ApplicationController
  param :id, Integer, required: true, desc: 'Product ID'
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/products/1

  #Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>,
    id: 2
  }

  ########### Response Example ################
  {
    product: {
      id: 15870,
      accounting_code: "",
      archived: false,
      barcode: "NTANKRENT",
      commission_rate_money: null,
      description: "RENTAL GEAR PER DAY",
      low_inventory_reminder: 5,
      markup: 0.0,
      name: "NITROX 80CU ALUMINUM (EAN 34 OR LESS FO2)",
      number_in_stock: 930,
      offer_price: null,
      retail_price: 17.0,
      sent_at: null,
      sku_code: "NTANKRENT",
      supplier_code: "",
      supply_price: 1.0,
      image: "/assets/missing/store_product/original.gif",
      brand: {
        id: 495,
        name: "GDC"
      },
      category: {
        id: 1333,
        name: "RENTAL"
      },
      supplier: {
        id: 655,
        name: "GDC"
      },
      commission_rate: {
        id: 426,
        amount: 0.0
      },
      tax_rate: {
        id: 607,
        amount: 7.0
      }
    }
  }
  '
  def show
    super
  end

  def_param_group :create do
    param_group :store_api_key, Api::V1::ApplicationController
    param :product, Hash, required: true, action_aware: true do
      param :name, String, required: true, desc: 'Product name'
      param :sku_code, String, required: true, desc: 'Product SKU Code'
      param :description, String, required: true, desc: 'Product description'
      param :number_in_stock, Integer, required: true, desc: 'Number of product items'
      param :low_inventory_reminder, Integer, required: 'Email will be sent when current stock count reaches this level'
      param :brand_id, Integer, required: true, desc: 'Brand ID of product'
      param :supplier_id, Integer, required: true, desc: 'Supplier ID of product'
      param :category_id, Integer, required: true, desc: 'Category ID of product'
      param :accounting_code, String, desc: 'Accounting code of product'
      param :supplier_code, String, desc: 'Supplier code of product'
      param :barcode, String, desc: 'Barcode of product'
      param :supply_price, Float, required: true, desc: 'Supply price of product. By defaul 0.0'
      param :markup, Float, required: true, desc: 'Markup of product. By default 0.0'
      param :retail_price, Float, required: true, desc: 'Retail Price of product'
      param :offer_price, Float, desc: 'Offer price of product'
      param :tax_rate_id, Integer, required: true, desc: 'Tax rate id of product. By default app uses detaul store tax rate'
      param :commission_rate_id, Integer, required: true, desc: 'Commission rate id of product. By default app uses default store commission rate'
    end
  end

  api :POST, '/v1/products', 'Create new product'
  param_group :create
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/products

  # Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>,
    product: {
      name: "Awesome Product",
      sku_code: "sku_1234",
      description: "Awesome super product",
      number_in_stock: 10,
      low_inventory_reminder: 1,
      brand_id: 101,
      category_id: 73,
      supplier_id: 399,
      accounting_code: "account_code_1234",
      supplier_code: "supplier_code_1234",
      barcode: "barcode_1234",
      supply_price: 100,
      markup: 0.0,
      retail_price: 150.55,
      offer_price: "",
      tax_rate_id: 238,
      commission_rate_id: 52
    }
  }

  ########### Response Example ################
  # SUCCESS
  no response

  #FAILURE
  {
    name: [
      "can\'t be blank"
    ],
    sku: [
      "can\'t be blank", "is not a number"
    ]
  }
  '
  def create
    super
  end

  api :PUT, '/v1/products/:id', 'Update exist product'
  param_group :create
  param :id, Integer, required: true, desc: 'Product ID'
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/products/1

  # Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>,
    id: 1,
    product: {
      name: "Awesome Product",
      sku_code: "sku_1234",
      description: "Awesome super product",
      number_in_stock: 10,
      low_inventory_reminder: 1,
      brand_id: 101,
      category_id: 73,
      supplier_id: 399,
      accounting_code: "account_code_1234",
      supplier_code: "supplier_code_1234",
      barcode: "barcode_1234",
      supply_price: 100,
      markup: 0.0,
      retail_price: 150.55,
      offer_price: "",
      tax_rate_id: 238,
      commission_rate_id: 52
    }
  }

  ########### Response Example ################
  # SUCCESS
  no response

  #FAILURE
  {
    name: [
      "can\'t be blank"
    ],
    sku: [
      "can\'t be blank", "is not a number"
    ]
  }
  '
  def update
    super
  end

  api :DELETE, '/v1/products/:id', "Delete product"
  param_group :store_api_key, Api::V1::ApplicationController
  param :id, Integer, desc: 'Product ID', required: true
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://api.divecentrehq.com/api/v1/products/1

  # Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>,
    id: 1
  }

  ########### Response Example ################
  no content
  '
  def destroy
    super
  end

  private
  def begin_of_association_chain
    current_store
  end

  def collection
    filter = params[:filter].present? && params[:filter] == 'archived' ? :archived : :unarchived
    @products = end_of_association_chain.includes([:brand, :category, :supplier, :tax_rate, :commission_rate]).send(filter).page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end

  def build_resource
    super.tap do |attr|
      attr.build_logo
      attr.store_id = current_store.id
    end
  end
end
