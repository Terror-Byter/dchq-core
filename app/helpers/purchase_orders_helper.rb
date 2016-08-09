module PurchaseOrdersHelper
  def suppliers_select
    select 'purchase_order',
           'supplier_id',
           options_from_collection_for_select(current_company.suppliers.order(:name), 'id', 'name'), {}, {class: 'selectpicker span12', "data-size" => "20"}
  end

  def delivery_locations_select
    select 'purchase_order',
           'delivery_location_id',
           options_from_collection_for_select(current_company.stores.order(:name), 'id', 'name'), {}, {class: 'selectpicker span12', "data-size" => "20"}
  end

  def print_partial
    'purchase_orders/print'
  end

  def print_partial_in_part
    'purchase_orders/print_in_part'
  end
end