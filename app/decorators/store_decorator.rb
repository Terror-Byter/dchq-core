class StoreDecorator < Draper::Decorator
  delegate_all
  #decorates_association :products
  decorates_association :customer_participants, scope: :need_show

  def no_sale_targets?
    model.sale_targets.empty?
  end

  def no_event_tariffs?
    model.event_tariffs.empty?
  end

  def no_standard_events?
    model.other_events.empty?
  end

  def products_stock_value
    h.formatted_currency(model.products.stock_value)
  end

  def products_count
    model.products.count
  end

  def products_in_stock
    model.products.in_stock.count
  end

  def products_out_of_stock
    model.products.out_of_stock.count
  end

  def revenue_this_month
    h.formatted_currency model.revenue_this_month
  end

  def average_sale_per_customer
    h.formatted_currency model.average_sale_per_customer
  end

  def print_tax
    model.tax_rate_inclusion? ? I18n.t('sales.details.inc_tax') : I18n.t('sales.details.exc_tax')
  end

  def service_types
    type_of_services.blank? ? type_of_services.build : type_of_services
  end

  def service_kits_types
    service_kits.blank? ? service_kits.build : service_kits
  end

  def names_type_of_services
    type_of_services.map{|u| [u.name, u.id]}
  end

  def currency_precision
    currency.precision
  end

  def booked_services
    services.booked_for_current_month.count
  end

  def in_progress_services
    services.in_progress_for_current_month.count
  end

  def awaiting_collection_services
    services.awaiting_collection_for_current_month.count
  end

  def complete_services
    services.complete_for_current_month.count
  end

  #def service_types
    #type_of_services.map{|u| [u.name, u.id]}
  #end

  def currency_unit
    currency.unit
  end

  def producss_names_and_ids
    products.map{|u| [u.name, u.id]}
  end
end
