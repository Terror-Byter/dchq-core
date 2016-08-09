class SaleDecorator < Draper::Decorator
  delegate_all
  decorates_association :sale_customers
  decorates_association :sale_products
  decorates_association :event_customer_participants

  def products
    "#{customer_sale_products}".html_safe
  end

  def customer_sale_products
    model.sale_products.map do |p|
      next if p.sale_productable.nil?
      product_name = "#{ p.quantity } x #{ p.sale_productable.name } (#{(h.formatted_currency(p.unit_price))})"
      if p.sale_productable_type == 'Product'
        h.link_to product_name, p.sale_productable
      elsif p.sale_productable_type == 'EventCustomerParticipant'
        h.link_to product_name, h.event_path(p.sale_productable.event)
      else
        product_name
      end
    end * ', '
  end

  def value
    h.formatted_currency(model.grand_total)
  end

  def outstanding
    h.formatted_currency(model.change_amount.abs)
  end

  def status_div
    status = model.human_status
    case status
    when "Complete"
      h.content_tag(:span, status, class: "label btn-success")
    when "Lay-by"
      h.content_tag(:span, status, class: "label btn-info")
    when "Active"
      h.content_tag(:span, status, class: "label btn-info")
    else
      h.content_tag(:span, status, class: "label btn-warning")
    end
  end

  def created_at
    l model.created_at, format: :default
  end

  def sale_path
    model.outstanding? ? h.edit_sale_path(model) : model
  end

  def creator_name
    model.creator.full_name
  end

  def customers
    model.customers.map{ |c| h.link_to c.full_name, h.customer_path(c) }.join(', ').html_safe
  end

  def image
    h.image_tag(h.current_company.logo.image(:large))
  end

  def mail_to_castomers
    model.customers.map{|u| u.email}.join(", ")
  end

  def store_name
    model.store.name
  end

  def company_address
    model.store.company.address.full_address
  end

  def company_telephone
    model.store.company.telephone
  end

  def company_email
    model.store.company.email
  end

  def sub_total_abs
    h.formatted_currency(model.sub_total.abs)
  end

  def tax_rate_total_abs
    h.formatted_currency(model.tax_rate_total.abs)
  end

  def print_discount
    return h.formatted_currency(0) unless model.discount
    h.formatted_discount(model.discount)
  end

  def grand_total_abs
    h.formatted_currency(model.grand_total)
  end

  def change_amount_abs
    h.formatted_currency(model.change_amount.abs)
  end

  def product_quantity
    sp = model.sale_products.only_products.find_by_sale_productable_id(h.params[:id])
    sp.nil? ? '-' : h.formatted_currency(sp.unit_price * sp.quantity)
  end
end
