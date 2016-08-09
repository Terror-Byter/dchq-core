desc "Products tasks"
namespace :product do
  desc 'Send Low Inventory Reminder'
  task :low_inventory_reminder => :environment do
    Store.joins(:company).enable_low_inventory_email.find_each do |store|
      store.send_product_reminder_email unless store.products.need_to_remind.empty?
    end
  end
end
