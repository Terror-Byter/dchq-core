module Api
  module V1
    class SalesController < Api::V1::ApplicationController

      actions :index, :show, :new
      custom_actions collection: [:products, :remove_customer],
                         member: [:add_customer, :add_product, :send_receipt, :add_misc_product]

      api :GET, '/v1/sales', 'Sales list for specific store'
      param_group :store_api_key, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/sales

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
      }

      ########### Response Example ################
      {
        sales: [
          {
            id: 432,
            created_at: "2012-06-27T08:03:38Z",
            grand_total: -300.0,
            status: layby,
            customers: [
              {
                id: 3809,
                full_name: Walk In
              }
            ],
            number_of_products: 3,
            number_of_services: 0,
            number_of_gift_cards: 0,
            number_of_events: 0
          },
          {
            id: 800,
            created_at: "2012-09-14T11:40:23Z",
            grand_total: 109.0,
            status: layby,
            customers: [
              {
                id: 4492,
                full_name: "Marcus Kapnoullas"
              }
            ],
            number_of_products: 0,
            number_of_services: 0,
            number_of_gift_cards: 0,
            number_of_events: 1
          }
        ]
      }
      '
      def index
        super
      end

      api :GET, '/v1/sales/products', 'Get Products List for cusrrent store'
      param_group :store_api_key, Api::V1::ApplicationController
      param :barcode, String, desc: 'Product Barcode'
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/sales/products

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
        barcode: "12343ss344"
      }
      ########### Response Example ################
      {
        products: [
          {
            id: 466,
            name: "Liquid Skin Mask [Yellow]",
            class_type: "Product"
          },
          {
            id: 476,
            name: "Dragon BCD [XS]",
            class_type: "Product"
          },
          {
            id: 477,
            name: "$25 gift card",
            class_type: "GiftCardType"
          }
        ]
      }
      '
      def products
        @products = begin_of_association_chain.products.unarchived.in_stock + current_company.gift_card_types.enable_sold
        @protects = begin_of_association_chain.products.in_stock.unarchived.where(barcode: params[:barcode]) if params[:barcode]
      end


      api :GET, '/v1/sales/:id', 'Get sale list details'
      param_group :store_api_key, Api::V1::ApplicationController
      param :id, Integer, desc: 'Sale ID', required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/sales/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
        id: 1
      }

      ########### Response Example ################
      {
        sale: {
          id: 2179,
          sub_total: 478.8025,
          tax_rate: 36.0,
          discount: null,
          grand_total: 514.8,
          change: 514.8,
          status: "active",
          payment_tendered: 1000,
          sale_customers: [
            {
              id: 714,
              customer: {
                id: 3809,
                full_name: "Walk In"
              }
            }
          ],
          sale_products: [
            {
              id: 1643,
              name: "Dragon BCD [XS]",
              unit_price: 400.0,
              quantity: 1,
              total: 396.0,
              discount: {
                created_at: "2013-07-04T08:40:48Z",
                discountable_id: 1643,
                discountable_type: "SaleProduct",
                id: 2821,
                kind: "percent",
                updated_at: "2013-07-04T08:40:48Z",
                value: 10.0
              }
            },
            {
              id: 1644,
              name: "25.00 Gift Card (valid for: 12 months)",
              unit_price: 25.0,
              quantity: 1,
              total: 25.0,
              discount: null
            }
          ],
          payments: [
            {
              id: 2223,
              amount: 123.0,
              created_at: "2013-07-08T11:31:19Z",
              updated_at: "2013-07-08T11:31:19Z",
              cashier: {
                id: 311,
                full_name: "Andre T",
              },
              payment_method: {
                id: 119,
                store_id: 117,
                name: "Visa",
                xero_code: ""
              }
            }
          ]
        }
      }
      '
      def show
        super
      end

      api :GET, '/v1/sales/new', 'Create new empty sale list'
      param_group :store_api_key, Api::V1::ApplicationController
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/sales/new

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
      }
      ########### Response Example ################
      {
        sale: {
          id: 2213
        }
      }
      '
      def new
        unless default_sale_list.available_limit_exceeded?
          create_sale
          render :new
        else
          raise LimitOfActiveSale
        end
      end

      api :POST, '/v1/sales/:id/add_customer', 'Add customer to sale list'
      param_group :store_api_key, Api::V1::ApplicationController
      param :id, Integer, desc: 'Sale ID', required: true
      param :customer_id, Integer, desc: 'Customer ID', required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/sales/233/add_customer

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
        customer_id: 12,
        id: 1
      }
      ########### Response Example ################
      #SUCCESS
      {
        notice: "Ok"
      }

      #FAILURE
      {
        error: "Error"
      }
      '
      def add_customer
        render( json: { error: 'Error' } ) and return if !resource.active?
        resource.sale_customers.create(customer_id: params[:customer_id]) unless resource.refunded?

        render json: { notice: 'Ok' }
      end

      api :POST, '/v1/sales/:id/add_product', 'Add product to sale list'
      param_group :store_api_key, Api::V1::ApplicationController
      param :id, Integer, desc: 'Sale ID', required: true
      param :product_id, Integer, desc: 'Product ID', required: true
      param :class_type, ['Product', 'GiftCardType'], desc: 'Product Type', required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/sales/233/add_product

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
        product_id: 12,
        class_type: "Product",
        id: 1
      }
      ########### Response Example ################
      #SUCCESS
      {
        notice: "Ok"
      }
      '
      def add_product
        prepare_gift_card if params[:class_type].eql?("GiftCardType")
        sale_product = resource.sale_products.find_by_sale_productable_id_and_sale_productable_type(params[:product_id], params[:class_type]) unless params[:class_type].eql?("GiftCardType")
        if sale_product
          sale_product.update_attribute :quantity, sale_product.quantity.next unless resource.refunded?
        else
          resource.sale_products.create(sale_productable_type: params[:class_type], sale_productable_id: params[:product_id]) unless resource.refunded?
        end
        render json: { notice: 'Ok' }
      end

      api :POST, '/v1/sales/remove_customer', 'Remove Customer From Sale List'
      param_group :store_api_key, Api::V1::ApplicationController
      param :sale_customer_id, Integer, desc: 'Sale Customer ID', required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/sales/remove_customer

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>
        sale_customer_id: 12
      }
      ########### Response Example ################
      #SUCCESS
      {
        notice: "Ok"
      }
      #FAILURE
      {
        error: "Customer Not Found"
      }
      '
      def remove_customer
        sale_customer = resource.sale_customers.find(params[:sale_customer_id])
        if sale_customer.destroy
          render json: { notice: 'Ok' }
        else
          render json: { error: 'Customer Not Found' }
        end
      end

      api :PUT, '/v1/sales/update/:id', 'Update Exist Sale List'
      param_group :store_api_key, Api::V1::ApplicationController
      param :id, Integer, desc: 'Sale ID', required: true
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/sales/update/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
        id: 1,
        sale: {
          sale_products_attributes: {
            0: {
              quantity: 3,
              id: 1643
            },
            1: {
              prod_discount_attributes: {
                value: 10.0,
                kind: "percent",
                _destroy: false,
                id: 2821
              },
              id: 1643
            },
            2: {
              quantity: 1,
              id: 1644
            }
          },
          event_customer_participants_attributes: {
            0: {
              event_customer_participant_discount_attributes: {
                value: 5.25,
                kind: "percent",
                _destroy: false,
                id: 2827
              },
              id: 3302
            }
          },
          payments_attributes: {
            1: {
              cashier_id: 311,
              customer_id: "2",
              amount: 23.4,
              payment_method_id: 99,
              amount_for_search: ""
            }
          }
        },
      }
      ########### Response Example ################
      #SUCCESS
      {
        no_content
      }
      '
      def update
        update! do |success, failure|
          if !params[:payment_type].blank? && resource.errors.blank? && resource.refund?
            resource.update_attributes(status: 'complete_refund') && resource.update_gift_cards_status if resource.can_be_completed? || resource.can_be_outstanding?
          end
        end
      end

      api :POST, '/v1/sales/:id/send_receipt', 'Send sale receipt'
      param_group :store_api_key, Api::V1::ApplicationController
      param :id, Integer, desc: 'Sale ID', required: true
      param :email, String, desc: 'Email address for receipt. If email is blank then app will send email to sale customer'
      formats [:json]
      example '
      ########### Request Example #################
      # URL
      https://app.divecentrehq.com/api/v1/sales/update/1

      # Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
        id: 1,
        email: "test@example.com"
      }
      ############### Response Example #############
      #SUCCESS
      {
        no_content
      }
      '
      def send_receipt
        email = params[:email] || resource.customers.first.email
        @sale = resource
        pdf = WickedPdf.new.pdf_from_string(render_to_string('sale_mailer/send_receipt.html.haml', layout: false, locals: { for_pdf: true }))
        SaleMailer.delay.send_receipt(resource, email, pdf_file: pdf)
        render json: { head: :ok }
      end

      api :POST, '/v1/sales/:id/add_misc_product', 'Add miscellaneous product to sale list'
      param_group :store_api_key, Api::V1::ApplicationController
      param :id, Integer, desc: 'Sale ID', required: true
      param :misc_product, Hash, required: true, action_aware: true do
        param :price, Float, required: true, desc: 'Price for miscellaneous product'
        param :tax_rate_id, Integer, required: true, desc: 'Tax Rate ID'
        param :category_id, Integer, required: true, desc: 'Category ID'
        param :description, String, required: false, desc: 'Description for your miscellaneous product'
      end
      formats [:json]
      example '
      ########## Request Example #################
      #URL
      https://app.divecentrehq.com/api/v1/sales/233/add_misc_product

      #Request Body
      {
        user_token: <USER_TOKEN>,
        store_api_key: <STORE_API_KEY>,
        id: 1,
        misc_product: {
          price: 100,
          tax_rate_id: 1,
          category_id: 1,
          description: "Misc Product description"
        }
      }
      ######### Response Example ################
      #SUCCESS
      {
        notice: "Ok"
      }

      #FAILURE
      {
        tax_rate_id: [
          "does not exist", "should be number"
        ],
        price: [
          "is not valid", "should be number"
        ]
      }
      '
      def add_misc_product
        @product = current_store.miscellaneous_products.create(params[:misc_product])
        if @product.new_record?
          render json: { errors: @product.errors.full_messages }
        else
          resource.sale_products.create(sale_productable_id: @product.id, sale_productable_type: @product.class.name, quantity: 1)
          render json: { head: :ok }
        end
      end

      protected
      def begin_of_association_chain
        current_store
      end

      def collection
        @sales ||= case params[:filter]
                   when 'layb-by' then end_of_association_chain.layby
                   when 'complete' then end_of_association_chain.completed
                   else  end_of_association_chain.outstanding
                   end
      end

      def prepare_gift_card
        gift_card_type = GiftCardType.find(params[:product_id])
        params[:class_type] = "GiftCard"
        params[:product_id] = gift_card_type.create_gift_card.id
      end
    end
  end
end
