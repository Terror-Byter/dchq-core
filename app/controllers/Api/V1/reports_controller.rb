class Api::V1::ReportsController < Api::V1::ApplicationController
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  actions :all, only: []

  custom_actions collection: [:sales_by_brand, :sales_by_category, :sales_by_products, :sales_by_day,
                              :sales_by_staff_member, :financial_reports, :financial_report_details]

  before_filter :parse_first_month_and_duration, only: [:sales_by_brand, :sales_by_category, :sales_by_products]

  api :GET, '/v1/reports/sales_by_brand', 'Return sum of sales for each brand'
  param_group :store_api_key, Api::V1::ApplicationController
  param :month, Integer, desc: "Number of month for which you want receive reports. By default it's current month"
  param :year, Integer, desc: "Year for which you want receive reports. By default it's current year"
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/reports/sales_by_brand

  # Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>
    month: 03
    year: 2014
  }

  ########### Response Example ################
  {
    "Mares": "$1140.00",
    "Scuba Pro": "$0.00",
    "Cressi": "$0.00",
    "OCEANIC": "$0.00",
    "my brand": "$0.00"
  }
  '
  def sales_by_brand
    report = {}
    current_store.brands.each do |brand|
      report[brand.name] = formatted_currency(brand.sale_products.where(created_at: @date.beginning_of_month..@date.end_of_month).sum(&:line_item_price))
    end
    render json: report
  end

  api :GET, '/v1/reports/sales_by_category', 'Return sum of sales for each category'
  param_group :store_api_key, Api::V1::ApplicationController
  param :month, Integer, desc: "Number of month for which you want receive reports. By default it's current month"
  param :year, Integer, desc: "Year for which you want receive reports. By default it's current year"
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/reports/sales_by_category

  # Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>
    month: 03
    year: 2014
  }

  ########### Response Example ################
  {
    "Masks": "$1140.00",
    "BCDs": "$0.00",
    "Fins": "$0.00"
  }
  '
  def sales_by_category
    report = {}
    current_store.categories.each do |category|
      report[category.name] = formatted_currency(category.sale_products.where(created_at: @date.beginning_of_month..@date.end_of_month).sum(&:line_item_price))
    end
    render json: report
  end

  api :GET, '/v1/reports/sales_by_products', 'Return sum of sales for each product'
  param_group :store_api_key, Api::V1::ApplicationController
  param :month, Integer, desc: "Number of month for which you want receive reports. By default it's current month"
  param :year, Integer, desc: "Year for which you want receive reports. By default it's current year"
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/reports/sales_by_products

  # Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>
    month: 03
    year: 2014
  }

  ########### Response Example ################
  {
    "36\" HP HOSE": "$39.95",
    "SPRING FIN STRAPS QUICK RELEASE MD": "$34.95",
    "KIT, SVC, CDX5, YOKE NON DVT": "$30.00",
    "KIT, SVC, STD 2ND STAGE": "$40.00",
    "VINYL VALVE PROTECTOR- NITROX": "$1.95"
  }
  '
  def sales_by_products
    report = {}

    products = current_store.sold_products

    products.sort_by{|e| e.sales.where(sales: { store_id: current_store.id}).count}.each do |product|
      report[product.name] = formatted_currency(current_store.sale_products.where(sale_productable_id: product.id, sale_productable_type: 'Product', created_at: @date.beginning_of_month..@date.end_of_month).sum(&:line_item_price))
    end

    render json: report
  end


  api :GET, '/v1/reports/sales_by_day', 'Return sum of sales for one day'
  param_group :store_api_key, Api::V1::ApplicationController
  param :date, Date, desc: "Date of day for report. By default date today"
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/reports/sales_by_day

  # Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>
    date: "2014-12-01"
  }

  ########### Response Example ################
  {
    "sales_inc_tax": "$0.00",
    "taxes": "$0.00",
    "taxable_revenue": "$0.00",
    "cost_of_goods": "$0.00",
    "gross_profit": "$0.00"
  }
  '
  def sales_by_day
    #need to exclude all sales with status == refund
    # AND also exclude the parent sale if status == refund
    report_by_day = { sales_inc_tax: [],
                      taxes: [],
                      taxable_revenue: [],
                      cost_of_goods: [],
                      gross_profit: [] }
    day = Date.parse(params[:date]) rescue Date.today


    @sales = current_store.sales.where(created_at: day.beginning_of_day..day.end_of_day)
    sales_inc_tax = @sales.sum(:taxable_revenue)
    cost_of_goods = @sales.sum(:cost_of_goods)
    report_by_day[:sales_inc_tax]   = formatted_currency(@sales.sum(:grand_total))
    report_by_day[:taxes]           = formatted_currency(@sales.sum(:tax_rate_total))
    report_by_day[:taxable_revenue] = formatted_currency(sales_inc_tax)
    report_by_day[:cost_of_goods]   = formatted_currency(cost_of_goods)
    report_by_day[:gross_profit]    = formatted_currency(sales_inc_tax - cost_of_goods)

    render json: report_by_day
  end

  api :GET, '/v1/reports/sales_by_staff_member', 'Return sum of sales for each staff member'
  param_group :store_api_key, Api::V1::ApplicationController
  param :date_start, Date, desc: "Start date for report. By default - beginning of month"
  param :date_end, Date, desc: "End date for report. By default - date today"
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/reports/sales_by_staff_member

  # Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>
    date_start: "2014-12-01"
    date_end: "2014-12-03"
  }

  ########### Response Example ################
  [
    {
      "John Doe": "$123.44",
      "Katy Kay": "$1000"
    }
  ]
  '
  def sales_by_staff_member
    report = []
    date_start = Date.parse(params[:date_start]) rescue Date.today.beginning_of_month
    date_end   = Date.parse(params[:date_end]) rescue Date.today
    current_store.users.uniq.each do |staff|
      sales = staff.sales.where( created_at: date_start..date_end )
      report << { name: staff.full_name,
                  total_sale: formatted_currency( sales.sum(:grand_total) ) }
    end
    render json: report
  end

  api :GET, '/v1/reports/financial_reports', 'Return list of financial reports for month'
  param_group :store_api_key, Api::V1::ApplicationController
  param :month, Integer, desc: "Number of month for which you want receive reports. By default it's current month"
  param :year, Integer, desc: "Year for which you want receive reports. By default it's current year"
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/reports/financial_reports

  # Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>
    month: 03
    year: 2014
  }

  ########### Response Example ################
  [
    {
      "id": 782,
      "name": "Sales Report (Stores::Invoice): 02 Jun, 2014 10:52am",
      "total_sale": "$207.00"
    },
    {
      "id": 783,
      "name": "Sales Report (Stores::Credit): 02 Jun, 2014 10:52am",
     "total_sale": "$112.00"
    }
  ]
  '
  def financial_reports
    report = []
    period = Date.strptime("#{params[:month]}/#{params[:year]}", "%B/%Y") rescue Date.today
    current_store.finance_reports.where(created_at: period.beginning_of_month.beginning_of_day..period.end_of_month.end_of_day).order("created_at DESC").each do |fr|
      report << {
        id: fr.id,
        name: "#{ I18n.t('reports.financial_reports.sales_report', type: fr.type)}: #{ I18n.l(fr.created_at, format: :default) }",
        total_sale: formatted_currency(fr.total_payments)
      }
    end
    render json: report
  end

  api :GET, '/v1/reports/financial_reports/:id', 'Return financial report details'
  param_group :store_api_key, Api::V1::ApplicationController
  param :year, Integer, desc: "Year for which you want receive reports. By default it's current year"
  param :id, Integer, required: true, desc: 'Financial Report ID'
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/reports/financial_reports/1

  # Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>
    id: 1
  }

  ########### Response Example ################
  {
    financial_report: {
      id: 890,
      sent: false,
      type: "Invoice",
      completed_sales: "$781.27",
      tax_total: "$29.26",
      discounts: "$6.25",
      total_payments: "$781.27",
      store: {
        id: 337,
        name: "MadisonScuba"
      },
      working_time: {
        open_at: "2014-07-13T10:22:26-05:00",
        close_at: "2014-07-13T16:57:42-05:00"
      },
      category_payments: [
        {
          name: "Bags and Boxes",
          price: "$29.95"
        },
        {
          name: "Mask Accessories",
          price: "$7.99"
        }
      ],
      payments_for_complete_sales: [
        {
          payment_type: "Check",
          amount: "$185.00",
          id: 1,
        },
        {
          payment_type: "VISA",
          amount: "$507.82",
          id: 2
        },
        {
          payment_type: "MasterCard",
          amount: "$88.45",
          id: 3
        }
      ],
      payments_for_layby_sales: [
      ],
      tills: [
        {
          id: 1,
          created_at: "2014-07-13T10:22:26-05:00",
          user_name: "Kurt Flitcroft",
          take_out: true,
          amount: "$0.00",
          notes: ""
        }
      ]
    }
  }
  '
  def financial_report_details
    @financial_report = current_store.finance_reports.find(params[:id])
  end

  api :PUT, '/v1/reports/financial_reports/:id', 'Update financial report details'
  param_group :store_api_key, Api::V1::ApplicationController
  param :id, Integer, required: true, desc: 'Financial Report ID'
  param :store, Hash, required: true, action_aware: true do
    param :finance_reports_attributes, Hash do
      param :finance_report_payments_attributes, Hash do
        param :custom_amount, Float, required: true, desc: 'Changed payment amount'
        param :id, Integer, required: true, desc: 'Financial report payment id. Should be required if you want update custom_amount value'
      end
      param :id, Integer, required: true, desc: 'Finance Report ID'
    end
    param :tills_attributes, Hash, action_aware: true do
      param :take_out, [true, false], required: true, desc: 'Till true - then take out, when false - then put in'
      param :amount, Float, required: true, desc: 'Amount value'
      param :notes, String, required: false, desc: 'Till note'
      param :id, Integer, required: true, desc: 'Till ID'
    end
  end
  formats [:json]
  example '
  ########### Request Example #################
  # URL
  https://app.divecentrehq.com/api/v1/reports/financial_reports/1

  # Request Body
  {
    user_token: <USER_TOKEN>,
    store_api_key: <STORE_API_KEY>,
    store: {
      finance_reports_attributes: {
        "0": {
          finance_report_payments_attributes: {
            "0": {
              custom_amount: 184.00,
              id: 1728
            },
            "1": {
              custom_amount: 508.82,
              id: 1729
            },
            "2": {
              custom_amount: 88.45,
              id: 1730
            }
          },
          id: 890
        }
      },
      tills_attributes: {
        "0": {
          take_out: 0,
          amount: 10.00,
          notes: "Awesome Note",
          id: 491
        }
      }
    }
  }

  ########### Response Example ################
  # SUCCESS
  no response

  #FAILURE
  {
    "store": [
      "can\'t be blank"
    ]
  }
  '
  def update_finance_report
    if current_store.update_attributes(params[:store])
      #@finance_report.send_invoice_to_xero(@client) if current_store.xero_connected? and current_store.xero.valid_tax_rate? and @finance_report.invoice?
      #@finance_report.send_credit_to_xero(@client) if current_store.xero_connected? and current_store.xero.valid_tax_rate? and !@finance_report.invoice?
      render nothing: true
    else
      render json: current_store.errors
    end
  end

  private
  def parse_first_month_and_duration
    @date = if params[:month].present? && params[:year].present?
              Date.parse("#{params[:month]}-#{params[:year]}")
            else
              Date.today
            end
  end
end
