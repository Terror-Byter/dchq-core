namespace :sale do
  desc 'Change customer for sale'
  task :change_customer, [:sale_id, :customer_id] => :environment do |t, args|
    customer = Sale.find(args.sale_id).sale_customers.first
    puts 'Sale has no customer' if customer.blank?
    customer.update_column :customer_id, args.customer_id
    puts "Changed"
  end

  task :update_amounts! => :environment do
    index = 1
    Sale.find_each do |sale|
      puts "Updated Sale ID:#{ sale.id } with number #{ index + 1 } form #{ Sale.count }" if sale.update_amounts!
      index += 1
    end
  end

  #task :move_ecp_to_sales, [:sale_id] => :environment do |t, args|
  task :move_ecp_to_sales  => :environment do
    Sale.find_each do |sale|
      puts "Processing Sale ID: #{ sale.id }"
      ecps = EventCustomerParticipant.where(sale_id: sale.id)
      next if ecps.blank?

      sale = Sale.find_by_id(sale.id)
      next if sale.blank?

      change = sale.change

      ecps.each do |ecp|

        sp = sale.sale_products.create sale_productable_type: 'EventCustomerParticipant',
                                       sale_productable_id: ecp.id,
                                       quantity: 1
        if discount = ecp.discount
          discount.update_attributes discountable_type: 'SaleProduct', discountable_id: sp.id
        end

        if ecp.event.course?
          if material_price = ecp.event.store.certification_level_costs.find_by_certification_level_id(ecp.event.certification_level_id).try(:material_price)
            sale.sale_products.create sale_productable_type: 'MaterialPrice',
              sale_productable_id: material_price.id,
              quantity: 1
          end
        end

        sp = sale.sale_products.create sale_productable_type: 'EventCustomerParticipantOptions::KitHire',
                                       sale_productable_id:    ecp.event_customer_participant_kit_hire.id,
                                       quantity: 1 if ecp.event_customer_participant_kit_hire && !ecp.event_customer_participant_kit_hire.unit_price.zero?

        if discount = ecp.event_customer_participant_kit_hire.try(:discount)
          discount.update_attributes discountable_type: 'SaleProduct', discountable_id: sp.id
        end


        sp = sale.sale_products.create sale_productable_type: 'EventCustomerParticipantOptions::Insurance',
                                  sale_productable_id: ecp.event_customer_participant_insurance.id,
                                  quantity: 1  if ecp.event_customer_participant_insurance && !ecp.event_customer_participant_insurance.unit_price.zero?

        if discount = ecp.event_customer_participant_insurance.try(:discount)
          discount.update_attributes discountable_type: 'SaleProduct', discountable_id: sp.id
        end

        ecp.event_customer_participant_transports.each do |ecp_t|
          next if ecp_t.quantity.zero? || ecp_t.unit_price.zero?
          sp = sale.sale_products.create sale_productable_type: ecp_t.class.name,
                                         sale_productable_id: ecp_t.id,
                                         quantity: ecp_t.dynamic_quantity

          if discount = ecp_t.discount
            discount.update_attributes discountable_type: 'SaleProduct', discountable_id: sp.id
          end

        end

        ecp.event_customer_participant_additionals.each do |ecp_a|
          next if ecp_a.quantity.zero? || ecp_a.unit_price.zero?
          sp = sale.sale_products.create sale_productable_type: ecp_a.class.name,
                                    sale_productable_id: ecp_a.id,
                                    quantity: ecp_a.dynamic_quantity

          if discount = ecp_a.discount
            discount.update_attributes discountable_type: 'SaleProduct', discountable_id: sp.id
          end

        end
      end

      EventCustomerParticipant.where(id: ecps).update_all({ sale_id: nil })

      sale.update_amounts!
      sale.update_column :change, change
    end
  end
end
