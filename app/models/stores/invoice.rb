module Stores
  class Invoice < Stores::FinanceReport
    with_options presence: true do |v|
      v.with_options numericality: true do |o|
        o.validates :discounts
        o.validates :tax_total
        o.validates :complete_payments
      end
    end

    def xero_attributes(status)
      {
        type: 'ACCREC',
        contact: {
          id: store.xero.contact_remote_id,
          name: store.name
       },
       date: Date.today,
       due_date: Date.today,
       invoice_number: "POS-#{created_at.strftime("%Y-%m-%d")}-#{id}",
       reference: 'POS Sales',
       status: status,
       line_items: generate_line_items,
       line_amount_types: 'Inclusive'
      }
    end

    private

    def generate_line_items
      line_items = []

      self.finance_report_payments.each do |fpm|
        line_items << {
          description: fpm.name,
          quantity: 1,
          unit_amount: fpm.custom_amount.to_f,
          account_code: store.payment_methods.find_by_name(fpm.name).try(:xero_code)
        }
      end

      current_store = store

      sales_complete = current_store.sales.for_invoice(working_time).completed
      rentals = current_store.rentals.for_invoice(working_time)

      services = current_store.services.where(sale_id: sales_complete.map(&:id))
      all_type_of_services = services.map(&:kits).flatten.map(&:type_of_service)

      flag = true
      current_store.tax_rates.each do |tax_rate|
        if tax_rate.amount == 0 && flag
          zero_tax_value = SaleProduct.where(
            sale_id: sales_complete.map(&:id),
            sale_productable_type: 'GiftCard'
          ).sum(&:line_item_price)
          flag = false
        else
          zero_tax_value = 0
        end

        type_of_services = all_type_of_services.select {|u| u.tax_rate == tax_rate }

        line_items << {
          description: "POS-#{created_at.strftime("%Y-%m-%d")} (Tax: #{tax_rate.amount}%)",
          quantity: 1,
          unit_amount:
            tax_rate.sale_products.where(
              sale_id: sales_complete.map(&:id),
              sale_productable_type: [
                'StoreProduct',
                'EventCustomerParticipant',
                'MaterialPrice',
                'EventCustomerParticipantOptions::KitHire',
                'EventCustomerParticipantOptions::Insurance',
                'EventCustomerParticipantOptions::Additional',
                'EventCustomerParticipantOptions::Transport'
              ]).sum(&:line_item_price_with_tax_rate) +
              type_of_services.map(&:total_price).sum +
              current_store.service_kits.where(tax_rate_id: tax_rate, type_of_service_id: type_of_services).
                sum(&:retail_price),
              # tax_rate.renteds.where(rental_id: rentals).sum(&:line_item_with_tax_rate),
          account_code: store.xero.default_sale_account
        }
      end
      line_items
    end
  end
end
