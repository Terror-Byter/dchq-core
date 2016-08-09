module Stores
  class Credit < Stores::FinanceReport
    def xero_attributes(status)
      {
        type: 'ACCRECCREDIT',
        contact: {
          id: store.xero.contact_remote_id,
          name: store.name
        },
        date: Date.today,
        status: status,
        line_amount_types: 'Inclusive',
        line_items: generate_line_items,
        updated_date_utc: Time.now,
        fully_paid_on_date: Time.now,
        credit_note_number: "CN POS_#{created_at.strftime("%Y-%m-%d")}-#{id}",
        sent_to_contact: false
      }
    end

    private

    def generate_line_items
      line_items = []

      # prepare variables
      current_store = store

      sales_refund = current_store.sales.for_credit(working_time)
      services = current_store.services.where(sale_id: sales_refund)
      all_type_of_services = services.map(&:type_of_service)

      flag = true
      current_store.tax_rates.each do |tax_rate|
        if tax_rate.amount == 0 && flag
          zero_tax_value = SaleProduct.where( sale_id: sales_refund, sale_productable_type: "GiftCard").sum(&:line_item_price)
          flag = false
        else
          zero_tax_value = 0
        end

        type_of_services = all_type_of_services.map{|u| u if u.tax_rate == tax_rate}.compact

        line_items << {
          description: "CN POS_#{self.created_at.strftime("%Y-%m-%d")} (Tax: #{tax_rate.amount}%)",
          quantity: 1,
          unit_amount:
            tax_rate.sale_products.where(
              sale_id: sales_refund,
              sale_productable_type: [
                'StoreProduct',
                'EventCustomerParticipant',
                'MaterialPrice',
                'EventCustomerParticipantOptions::KitHire',
                'EventCustomerParticipantOptions::Insurance',
                'EventCustomerParticipantOptions::Additional',
                'EventCustomerParticipantOptions::Transport'
              ]).
            sum(&:line_item_price_with_tax_rate) +
            type_of_services.sum(&:total_price) +
            current_store.service_kits.where(tax_rate_id: tax_rate, type_of_service_id: type_of_services).
              sum(&:retail_price),
          account_code: store.xero.default_sale_account
        }
      end
      line_items
    end
  end
end
