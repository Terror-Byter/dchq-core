module ApplicationHelper

  def formatted_currency(value, options = {})
    number_to_currency(value.blank? ? 0 : value, @current_store.currency.format_options.merge(options)).html_safe
  end

  def colon value = nil
    "#{value}:" unless value.blank?
  end

  def customer_equipment_to_human value
    return t("helpers.application.own") if value
    t("helpers.application.rent")
  end

  def show_company_logo store, options = {}
    store.company.logo.image.exists? ? image_tag("#{ Figaro.env.host }#{ store.company.logo.image.url(:pdf) }", options) : store.name
  end

  def til value = nil
    return ' - ' if value.blank?
    value
  end

  def dashboard_active?
    [:pages].include?(controller_name.to_sym)
  end

  def events_active?
    [:events, :event_user_participants, :event_customer_participants, :other_events, :course_events].include?(controller_name.to_sym) && !sale_history_active?
  end

  def event_calendar_active?
    events_active? && action_name == 'index'
  end

  def event_list_active?
    events_active? && action_name == 'list'
  end

  def sales_active?
    pos_active? || sale_history_active? || sale_products_active? || sale_brands_active? || sale_categories_active? ||
    purchase_orders_active? || sale_gift_card_types_active? || sale_credit_notes_active? || sale_event_tariffs_active?
  end

  def pos_active?
    [:sales].include?(controller_name.to_sym) && [:index, :edit].include?(action_name.to_sym)
  end

  def sale_history_active?
    [:sales].include?(controller_name.to_sym) && [:history, :show].include?(action_name.to_sym)
  end

  def sale_products_active?
    [:products].include?(controller_name.to_sym)
  end

  def sale_brands_active?
    [:brands].include?(controller_name.to_sym)
  end

  def sale_categories_active?
    [:categories].include?(controller_name.to_sym)
  end

  def purchase_orders_active?
    [:purchase_orders].include?(controller_name.to_sym)
  end

  def sale_gift_card_types_active?
    [:gift_card_types].include?(controller_name.to_sym)
  end

  def sale_credit_notes_active?
    [:credit_notes].include?(controller_name.to_sym)
  end

  def sale_event_tariffs_active?
    [:event_tariffs].include?(action_name.to_sym)
  end

  def crm_active?
    crm_customers_active? || crm_suppliers_active? || crm_staffs_active? || crm_scheduling_active? || crm_smart_lists_active?
  end

  def crm_customers_active?
    [:customers].include?(controller_name.to_sym)
  end

  def crm_suppliers_active?
    [:suppliers, :business_contacts].include?(controller_name.to_sym)
  end

  def crm_staffs_active?
    [:staff_members].include?(controller_name.to_sym)
  end

  def crm_scheduling_active?
    #TODO
  end

  def crm_smart_lists_active?
    [:smart_lists].include?(controller_name.to_sym)
  end

  def crm_reviews_active?
    [:reviews].include?(controller_name.to_sym)
  end

  def crm_requests_active?
    [:requests].include?(controller_name.to_sym)
  end

  def reports_active?
    report_sales_by_day_active? || report_sales_by_month_active? || report_sales_by_year_active? || report_sales_by_staff_active? ||
    report_sales_by_brand_active? || report_sales_by_category_active? || report_sales_by_popular_active? ||
    report_event_sales_active? || report_financial_reports_active?
  end

  def report_sales_by_day_active?
    [:reports].include?(controller_name.to_sym) && [:sales_by_day].include?(action_name.to_sym)
  end

  def report_sales_by_month_active?
    [:reports].include?(controller_name.to_sym) && [:sales_by_month].include?(action_name.to_sym)
  end

  def report_sales_by_year_active?
    [:reports].include?(controller_name.to_sym) && [:sales_by_year].include?(action_name.to_sym)
  end

  def report_sales_by_staff_active?
    [:reports].include?(controller_name.to_sym) && [:sales_by_staff].include?(action_name.to_sym)
  end

  def report_sales_by_brand_active?
    [:reports].include?(controller_name.to_sym) && [:sales_by_brand].include?(action_name.to_sym)
  end

  def report_sales_by_category_active?
    [:reports].include?(controller_name.to_sym) && [:sales_by_category].include?(action_name.to_sym)
  end

  def report_sales_by_popular_active?
    [:reports].include?(controller_name.to_sym) && [:sales_by_popular].include?(action_name.to_sym)
  end

  def report_event_sales_active?
    [:reports].include?(controller_name.to_sym) && [:event_sales].include?(action_name.to_sym)
  end

  def report_financial_reports_active?
    [:reports].include?(controller_name.to_sym) && [:financial_reports].include?(action_name.to_sym)
  end

  def services_active?
    services_all_active? || services_booked_active? || services_in_progress_active? || services_to_collect_active? || services_complete_active?
  end

  def services_all_active?
    [:services].include?(controller_name.to_sym) && params[:filter].blank?
  end

  def services_booked_active?
    [:services].include?(controller_name.to_sym) && params[:filter] == 'booked'
  end

  def services_in_progress_active?
    [:services].include?(controller_name.to_sym) && params[:filter] == 'in_progress'
  end

  def services_to_collect_active?
    [:services].include?(controller_name.to_sym) && params[:filter] == 'awaiting_collection'
  end

  def services_complete_active?
    [:services].include?(controller_name.to_sym) && params[:filter] == 'complete'
  end

  def rentals_active?
    rental_products_active? || all_rentals_active? || booked_rentals_active? ||
    in_progress_rentals_active? || overdue_rentals_active? || complete_rentals_active? || pay_pending_rentals_active?
  end

  def rental_products_active?
    [:rental_products].include?(controller_name.to_sym)
  end

  def all_rentals_active?
    [:rentals].include?(controller_name.to_sym) && params[:filter].blank?
  end

  def pay_pending_rentals_active?
    [:rentals].include?(controller_name.to_sym) && params[:filter] == 'pay_pending'
  end

  def booked_rentals_active?
    [:rentals].include?(controller_name.to_sym) && params[:filter] == 'booked'
  end

  def in_progress_rentals_active?
    [:rentals].include?(controller_name.to_sym) && params[:filter] == 'in_progress'
  end

  def overdue_rentals_active?
    [:rentals].include?(controller_name.to_sym) && params[:filter] == 'overdue'
  end

  def complete_rentals_active?
    [:rentals].include?(controller_name.to_sym) && params[:filter] == 'complete'
  end

  def formatted_discount(discount)
    return "" unless discount
    discount.percent? ? "#{discount.value.abs}%" : formatted_currency(discount.value.abs)
  end

  def distance_in_days starts_at, ends_at
    days = (ends_at - starts_at) / 3600 / 24
    if days < 1 and days >= 0
      days = 1
    else
      days = days.round
    end
    pluralize(days, t("helpers.application.day"))
  end

  def print_barcode_html barcode
    barcode.to_html({height: '65px', css: false, width: "auto"}).gsub('\"', '').html_safe
  end

  def print_barcode_svg barcode
    barcode.to_svg.html_safe
  end

  def amount_with_precision amount = 0
    number_with_precision amount, precision: @current_store.currency.precision
  end

  def pluralize_without_count(count, singular, plural = nil)
    pluralize(count, singular, plural).gsub(/^\d+\s/, '')
  end

  def nl2br(s)
    s.blank? ? '' : raw(s.gsub(/\n/, '<br>'))
  end

  def body_attributes
    { class: body_class, id: body_id }
  end

  def body_class
    [controller.controller_name.dasherize]
  end

  def body_id
    "#{controller.controller_name.dasherize}-#{controller.action_name.dasherize}"
  end

  def uk_currency?
    current_store.currency.code == 'GBP'
  end

  def denmark_currency?
    current_store.currency.code == 'DKK'
  end

  def tsp_formatted_currency number
    (uk_currency? ? "##{ number_with_precision(number, precision: 2) }" : formatted_currency(number)).html_safe
  end

  def tsp_international
    return "international:'uk',".html_safe if uk_currency?
    return "international:'denmark',".html_safe if denmark_currency?
  end
end
