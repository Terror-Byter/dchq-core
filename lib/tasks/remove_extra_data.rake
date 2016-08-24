namespace :remove_extra_data do
  task except_company: :environment do
    ENV['from_rake_task'] = 'true'

    PaperTrail.enabled = false

    companies = Company.where("id != ?", ENV['company_id'])

    companies.find_each do |company|
      puts "*******Starting remove data from company #{ company.name }"

      puts '*******Removing Users:'
      #remove users
      deleted_user_ids = []
      User.with_deleted.where("company_id != ?", company.id).each do |user|
        puts "*******Removing user id = #{ user.id}, full name = #{ user.full_name }"

        puts "*******Removing address"
        user.address.try(:destroy!)
        puts '*******Removing notes'
        user.notes.destroy_all
        puts '*******Removing Avatar'
        user.avatar.try(:delete)
        puts '*******Removing holidays'
        user.user_holidays.destroy_all
        puts '*******Removing tills'
        user.tills.delete_all
        puts '*******Removing rentals'
        user.rentals.destroy_all
        puts '*******Removing sales'
        user.sales.map(&:destroy!)
        puts '*******Remove versions'


        deleted_user_ids << user.id

        puts '*******Removing user'
        user.destroy!

        puts '*******User removed'
      end

      company.stores.each do |store|
        store.certification_levels.destroy_all
        store.certification_level_costs.destroy_all
        store.payment_methods.with_deleted.map(&:destroy!)
        store.tax_rates.with_deleted.map(&:destroy!)
        store.commission_rates.with_deleted.map(&:destroy!)
        store.event_trips.delete_all

        # store.events.with_deleted.map(&:event_customer_participants)
        #
        # has_many :events
        # has_many :course_events
        # has_many :other_events

        # store.customers

        store.boats.destroy_all

        store.boats.destroy_all
        store.working_times.destroy_all
        store.event_tariffs.destroy_all
        store.finance_reports.destroy_all
        store.email_setting.try(:destroy)
        store.kit_hires.destroy_all
        store.transports.destroy_all
        store.insurances.destroy_all
        store.additionals.destroy_all

        store.type_of_services.destroy_all
        store.service_kits.destroy_all
        store.services.map(&:destroy)
        store.categories.find_each do |category|
          category.products.with_deleted.map(&:logo).map{ |logo| logo.try(:delete) }
          category.products.with_deleted.map(&:destroy!)
          category.destroy
        end

        store.brands.find_each do |brand|
          brand.logo.try(:delete)
          brand.products.with_deleted.map(&:logo).map{ |logo| logo.try(:delete) }
          brand.products.with_deleted.map(&:destroy!)
          brand.delete
        end

        store.products.with_deleted.find_each do |product|
          product.logo.try(:delete)
          product.service_items.map(&:destroy)
          product.delete
        end

        store.miscellaneous_products.map(&:destroy)
        store.sales.with_deleted.find_each do |sale|
          sale.discount.try(&:destroy)
          sale.event_customer_participants.with_deleted.map(&:destroy!)
          sale.sale_products.map(&:refunded_sale_products).map(&:delete)
          sale.sale_products.map(&:delete)
          sale.sale_customers.map(&:delete)
          sale.payments.map(&:delete)
          sale.credit_notes.map(&:destroy)
          sale.products.with_deleted.map(&:logo).map(&:delete)
          sale.products.with_deleted.map(&:destroy!)
          sale.destroy!
        end

        store.tills.destroy_all

        store.renteds.map(&:destroy)
        store.rental_products.destroy_all
        store.rentals.map{ |d| d.destory }

        store.xero.try(:destroy)
        store.scuba_tribe.try(:destroy)
        store.avatar.try(:delete)

        # store.destroy

      end
    end

    # PaperTrail::Version.find_each do |p|
    #   p.delete
    # end
  end
end