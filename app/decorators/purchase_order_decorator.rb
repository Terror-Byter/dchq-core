class PurchaseOrderDecorator < Draper::Decorator
  delegate_all

  def expected_delivery
    format_date :default
  end

  #noinspection RubyInstanceMethodNamingConvention
  def expected_delivery_for_datepicker
    format_date :date_only
  end

  def has_expected_delivery?
    model.expected_delivery.present?
  end

  def supplier_address
    format_address model.supplier.try(:address).try(:full_address)
  end

  def supplier_email_for_inputs
    return '' if model.supplier.nil?

    if model.supplier.email.present?
      model.supplier.email
    else
      ''
    end
  end

  def delivery_location_address
    format_address model.delivery_location.company.address.full_address
  end

  def grand_total
    h.formatted_currency(model.grand_total)
  end

  def fixed_total
    h.formatted_currency(model.fixed_total)
  end

  def status
    model.status.text
  end

  def last_updated
    h.l(model.updated_at)
  end

  def link_to_supplier
    if model.supplier
      h.link_to(model.supplier.name, model.supplier)
    else
      h.til
    end
  end

  def creator
    model.creator.full_name
  end

  def link_to_assign_supplier(text)
    show = model.supplier.nil?
    h.link_to(
        text,
        '#assign-supplier-modal',
        {
            id: 'assign-supplier-link',
            class: 'details pull-right',
            style: show ? 'display: block;' : 'display: none;',
            data: {toggle: 'modal'}
        })
  end

  def purchase_order_items
    PurchaseOrderItemDecorator.decorate_collection(model.purchase_order_items)
  end

  private

  def format_date(format)
    val = h.til(model.expected_delivery)
    if val.is_a? String
      val
    else
      l val, format: format
    end
  end

  def format_address addr
    if addr.blank?
      h.til
    else
      addr
    end
  end
end

# collection decorator for PurchaseOrder
class PurchaseOrdersDecorator < PaginatingDecorator; end