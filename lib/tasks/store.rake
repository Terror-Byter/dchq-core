namespace :store do
  desc 'Update FinanceReport calcs'
  task :update_finance_reports, [:store_id] => :environment do |t, args|
    store = Store.find(args.store_id)

    store.invoices.where(sent: false).each do |fr|
      sales = store.sales.for_invoice(fr.working_time)

      fr.destroy and next if sales.blank?

      fr.update_attributes total_payments: sales.sum(:grand_total),
                           discounts: sales.sum(&:calc_discount),
                           tax_total: sales.sum(:tax_rate_total),
                           complete_payments: sales.where( status: 'complete' ).sum(:grand_total)

      fr.finance_report_payments.destroy_all

      payments = []

      sales.each do |sale|
        sale.payments.each_with_index do |payment, index|
          payments << {payment.payment_method_id => (index + 1 == sale.payments.count) ? payment.amount - sale.change_amount : payment.amount}
        end
      end

      unless payments.blank?
        payments.inject{|memo, el| memo.merge( el ){|k, old_v, new_v| old_v + new_v}}.each do |pm|
          fr.finance_report_payments.create name: PaymentMethod.find_by_id(pm.first).name, amount: pm.last, custom_amount: pm.last
        end
      end
    end

    #CREDIT

    store.credits.where(sent: false).each do |fr|
      refund_sales = store.sales.for_credit(fr.working_time)

      fr.destroy and next if refund_sales.empty?

      fr.update_attributes total_payments: refund_sales.sum(:grand_total).abs,
                           complete_payments: refund_sales.sum(:grand_total).abs,
                           tax_total: refund_sales.sum(:tax_rate_total).abs,
                           discounts: 0

      fr.finance_report_payments.destroy_all

      Payment.where(sale_id: refund_sales.map(&:id)).sum(:amount, group: 'payment_method_id').each do |pm|
        fr.finance_report_payments.create name: PaymentMethod.find_by_id(pm.first).name, amount: pm.last.abs, custom_amount: pm.last.abs
      end
    end
  end
end
