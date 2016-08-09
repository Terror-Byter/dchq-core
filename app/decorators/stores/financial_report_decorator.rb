class Stores::FinancialReportDecorator < Draper::Decorator
  delegate_all

  def category_payments
    list = []
    sale_products = h.current_store.sales.for_invoice(model.working_time)

    h.current_store.categories.each do |c|
      price = SaleProduct.where(sale_id: sale_products.map(&:id), sale_productable_id: c.all_product_ids).sum(&:line_item_price)
       list << { name: c.name, price: h.formatted_currency(price) } unless price.zero?
    end

    SaleProduct.only_services.where(sale_id: sale_products.map(&:id)).each do |s|
      list << { name: s.sale_productable.type_of_service.name_for_sale, price: s.sale_productable.type_of_service.decorate.price} unless s.sale_productable.complimentary_service

      if s.sale_productable.type_of_service.service_kit
        price = s.sale_productable.type_of_service.service_kit.line_item_price
        list << { name: s.sale_productable.type_of_service.service_kit.name_for_sale, price: h.formatted_currency(price) } unless price.zero?
      end

      s.sale_productable.products.each do |p|
        list << { name: p.name, price: p.decorate.price }
      end
    end

    list
  end

  def payments_for_complete_sales
    list = []
    model.finance_report_payments.complete.each do |p|
      list << { id: p.id, payment_type: p.name, amount: h.formatted_currency(p.amount) }
    end
    list
  end

  def payments_for_layby_sales
    list = []
    model.finance_report_payments.where{ payment_id.not_eq nil }.each do |p|
      list << { id: p.id, payment_type: p.name, amount: h.formatted_currency(p.amount) }
    end
    list
  end

  def tills
    list = []
    h.current_store.tills.where(created_at: model.working_time.open_at..model.working_time.close_at).each do |t|
      list << { id: t.id, created_at: t.created_at, user_name: t.user.full_name, take_out: t.take_out?, amount: h.formatted_currency(t.amount), notes: t.notes  }
    end
    list
  end
end
