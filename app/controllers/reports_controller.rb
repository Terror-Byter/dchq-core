class ReportsController < InheritedResources::Base
  actions :all, only: [:index]
  respond_to :html, :js
  custom_actions collection: [:sales_by_day,
                              :sales_by_month,
                              :sales_by_year,
                              :sales_by_staff,
                              :sales_by_brand,
                              :sales_by_category,
                              :sales_by_popular,
                              :event_sales,
                              :update_finance_report,
                              :edit_finance_report
                             ]

  before_filter :init_report, only: [:sales_by_day, :sales_by_month, :sales_by_year]
  before_filter :parse_first_month_and_duration,
    only: [:sales_by_staff,
           :sales_by_brand,
           :sales_by_category,
           :sales_by_popular,
           :event_sales,
           :sales_by_year]
  before_filter :check_that_finance_report_not_sent, only: [:update_finance_report]

  def financial_reports
    @period = Date.strptime("#{params[:month]}/#{params[:year]}", "%B/%Y") rescue Date.today
    @finance_reports = current_store.finance_reports.where(created_at: @period.beginning_of_month.beginning_of_day..@period.end_of_month.end_of_day).order("created_at DESC")
  end

  def edit_finance_report
    @finance_report = current_store.finance_reports.find_by_id(params[:id])
    @finance_report.working_time.update_attributes close_at: Time.now, closed_user_id: current_user.id if @finance_report.working_time.close_at.blank?
    @tills = current_store.tills.where(created_at:  @finance_report.working_time.open_at..@finance_report.working_time.close_at)
  end

  def update_finance_report
    @finance_report = current_store.finance_reports.find_by_id(params[:id])
    if current_store.update_attributes(params[:store])
      if current_store.xero.end_of_day?
        xero = Xero.new(current_store)
        xero.send_report(@finance_report)
      end

      redirect_to(
        financial_reports_reports_path,
        notice: "#{@finance_report.invoice? ? 'Invoice' : 'Credit'} changed successfully"
      ) if @finance_report.errors.blank?
      render action: :edit_finance_report unless @finance_report.errors.blank?
    else
      render action: :edit_finance_report
    end
  end

  def sales_by_day

    #need to exclude all sales with status == refund
    # AND also exclude the parent sale if status == refund

    @report_by_day = { sales_inc_tax: [],
                        taxes: [],
                        taxable_revenue: [],
                        cost_of_goods: [],
                        gross_profit: [],
                        refunds: [],
                        tax_refunds: [] }
    @day = Date.parse(params[:date]) rescue Date.today

    @number_of_days = 3

    (@day - @number_of_days.days..@day + @number_of_days.days).each do |date|
      @sales = current_store.sales.for_report.includes(:sale_products).where(created_at: date.beginning_of_day..date.end_of_day)
      refunds = current_store.sales.refunded.includes(:sale_products).where(created_at: date.beginning_of_day..date.end_of_day)
      @report_by_day[:sales_inc_tax] << @sales.sum(:grand_total)
      @report_by_day[:taxes] << @sales.sum(:tax_rate_total)
      @report_by_day[:taxable_revenue] << @sales.sum(:taxable_revenue)
      @report_by_day[:cost_of_goods] << @sales.sum{ |s| s.calc_cost_of_goods }
      @report_by_day[:gross_profit] << (@report_by_day[:sales_inc_tax].last - @report_by_day[:cost_of_goods].last)
      @report_by_day[:refunds] << refunds.sum(:grand_total)
      @report_by_day[:tax_refunds] << refunds.sum(:tax_rate_total)
    end
  end

  def sales_by_month
    #need to exclude all sales with status == refund
    # AND also exclude the parent sale if status == refund

    @date = params[:month].present? && params[:year].present? ? Date.parse("#{params[:month]} #{params[:year]}") : Date.today

    @report_by_month = { sales_inc_tax: [],
                        taxes: [],
                        taxable_revenue: [],
                        cost_of_goods: [],
                        gross_profit: [],
                        refunds: [],
                        tax_refunds: [] }

    @duration = 3
    @duration.times do |index|
      date = (@date + index.month).to_time
      @sales = current_store.sales.for_report.includes(:sale_products).where(created_at: date.beginning_of_month..date.end_of_month)
      refunds = current_store.sales.refunded.includes(:sale_products).where(created_at: date.beginning_of_month..date.end_of_month)
      @report_by_month[:sales_inc_tax] << @sales.sum(:grand_total)
      @report_by_month[:taxes] << @sales.sum(:tax_rate_total)
      @report_by_month[:taxable_revenue] << @sales.sum(:taxable_revenue)
      @report_by_month[:cost_of_goods] << @sales.sum{|s| s.calc_cost_of_goods}
      @report_by_month[:gross_profit] << (@report_by_month[:sales_inc_tax].last - @report_by_month[:cost_of_goods].last)
      @report_by_month[:refunds] << refunds.sum(:grand_total)
      @report_by_month[:tax_refunds] << refunds.sum(:tax_rate_total)
    end
  end

  def sales_by_year
    #need to exclude all sales with status == refund
    # AND also exclude the parent sale if status == refund

    @report_by_year = { sales_inc_tax: [],
                        taxes: [],
                        taxable_revenue: [],
                        cost_of_goods: [],
                        gross_profit: [],
                        refunds: [],
                        tax_refunds: [] }
    @period = 3
    (0..@period).to_a.reverse.each do |index|
      date = Date.today - index.years
      @sales = current_store.sales.for_report.includes(:sale_products).where(created_at: date.beginning_of_year..date.end_of_year)
      refunds = current_store.sales.refunded.includes(:sale_products).where(created_at: date.beginning_of_month..date.end_of_month)
      @report_by_year[:sales_inc_tax] << @sales.sum(:grand_total)
      @report_by_year[:taxes] << @sales.sum(:tax_rate_total)
      @report_by_year[:taxable_revenue] << @sales.sum(:taxable_revenue)
      @report_by_year[:cost_of_goods] << @sales.sum{ |s| s.calc_cost_of_goods }
      @report_by_year[:gross_profit] << (@report_by_year[:sales_inc_tax].last - @report_by_year[:cost_of_goods].last)
      @report_by_year[:refunds] << refunds.sum(:grand_total)
      @report_by_year[:tax_refunds] << refunds.sum(:tax_rate_total)
    end
  end

  def event_sales
    @report = {}
    @report[:dive_courses] = []
    @report[:dive_trips] = []
    @report[:total] = []
    @duration.times do |index|
      date = @date + index.month
      sales = current_store.sales.for_report.includes([:event_customer_participants, :discount]).where(created_at: date.beginning_of_month..date.end_of_month)
      @report[:dive_courses] << sales.sum(:course_events_total_price)
      @report[:dive_trips] << sales.sum(:other_events_total_price)
      @report[:total] << @report[:dive_courses][index] + @report[:dive_trips][index]
    end
  end

  def sales_by_staff
    @report = []
    @date_start = Date.parse(params[:date_start]) rescue Date.today.beginning_of_month
    @date_end   = Date.parse(params[:date_end]) rescue Date.today
    current_store.users.uniq.each do |staff|
      @sales = staff.sales.where(completed_at: @date_start..@date_end)
      @report << { name: staff.full_name,
                   total_sale: @sales.sum(:grand_total),
                   comission_total: calc_comission_rate_total(@sales),
                   comission_earned: calc_comission_earned(@sales) }
    end
  end


  def sales_by_brand
    @report = {}
    current_store.brands.each do |brand|
      @report[brand.name] = []
      @duration.times do |index|
        date = @date + index.month
        @report[brand.name] << brand.sale_products.includes(
          [:prod_discount, :sale, :sale_productable]
        ).where(sales: { completed_at: date.beginning_of_month..date.end_of_month }).sum(&:line_item_price)
      end
    end
  end

  def sales_by_category
    @report = {}
    current_store.categories.each do |category|
      @report[category.name] = []
      @duration.times do |index|
        date = @date + index.month
        @report[category.name] << category.sale_products.includes(
          [:prod_discount, :sale, :sale_productable]
        ).where(sales: { completed_at: date.beginning_of_month..date.end_of_month }).sum(&:line_item_price)
      end
    end
  end

  def sales_by_popular
    @report = {}

    @products = current_store.sold_products.page(params[:page]).per(50)
    @products = @products.where(id: params[:product_ids]) unless params[:product_ids].blank?

    @products.sort_by{|e| e.sales.where(sales: { store_id: current_store.id}).count}.each do |product|
      @report[product.name] = []
      @duration.times do |index|
        date = @date + index.month
        @report[product.name] << current_store.sale_products.where(sale_productable_id: product.id, sale_productable_type: 'Product', created_at: date.beginning_of_month..date.end_of_month).sum(:smart_line_item_price)
      end
    end
  end

  def check_access
    redirect_to root_path, alert: I18n.t("controllers.check_access") unless current_user.try(:manager?)
  end

  private
  def init_report
    @report = { sales_inc_tax: [],
                taxes: [],
                cost_of_goods: [],
                gross_profit: [] }
  end

  def parse_first_month_and_duration
    @duration = params[:duration] && params[:duration].to_i || 9
    @date = if params[:month].present? && params[:year].present?
      Date.parse("#{params[:month]} #{params[:year]}")
    else
      (@duration - 1).months.ago
    end
  end

  def check_that_finance_report_not_sent
    redirect_to :back, alert: "You can't edit this invoice as it's been sent to Xero." if current_store.finance_reports.find_by_id(params[:id]).sent?
  end

  def calc_comission_rate_total sales
    sales.inject(0){ |sum, sale| sum + sale.sale_products.only_products.map(&:calc_comission_rate).sum }
  end

  def calc_comission_earned sales
    sales.inject(0){ |sum, sale| sum + sale.sale_products.only_products.map(&:calc_comission_earned).sum }
  end
end
