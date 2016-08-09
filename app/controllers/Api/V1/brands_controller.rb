module Api
  module V1
    class BrandsController < Api::V1::ApplicationController
      actions :index

      api :GET, '/v1/brands', 'Get all brands for store'
      param_group :store_api_key, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://api.divecentrehq.com/api/v1/brands

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
      }

      ########### Response Example ################
      {
        "brands": [
          {
            "id": 73,
            "name": "Masks",
            "description": "",
            "created_at": "2012-02-11T07:36:09Z",
            "updated_at": "2012-02-11T07:36:09Z"
          },
          {
            "id": 74,
            "name": "BCDs",
            "description": "",
            "created_at": "2012-02-11T07:36:19Z",
            "updated_at": "2012-02-11T07:36:19Z"
          }
        ]
      }
      '
      def index
        super
      end

      api :GET, '/v1/brands/:id', 'Get brand details'
      param_group :store_api_key, Api::V1::ApplicationController
      param :id, Integer, required: true, desc: 'Brand ID'
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://api.divecentrehq.com/api/v1/brands/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
        id: 1
      }

      ########### Response Example ################
     {
       brand: {
         id: 876,
         name: "HOG",
         description: null,
         created_at: "2014-03-06T21:09:56Z",
         updated_at: "2014-03-06T21:09:56Z",
         units_in_stock: 4,
         stock_value: "28.00",
         avg_monthly_sale: 0,
         last_sale: "28 Aug, 2014 01:26am",
         products: [
           {
             id: 24780,
             accounting_code: "",
             archived: false,
             barcode: "",
             commission_rate_money: null,
             description: "We took a classic and made it better!",
             low_inventory_reminder: 5,
             markup: 0.0,
             name: "HOG Tech 2 Fin - Black - XXL",
             number_in_stock: 0,
             offer_price: null,
             retail_price: "150.0",
             sent_at: null,
             sku_code: "EDG0160-2X-BK",
             supplier_code: "",
             supply_price: "80.0"
           },
         ]
       }
      }
      '
      def show
        super
      end

      private
      def begin_of_association_chain
        current_store
      end
    end
  end
end
