desc "This task is called by the Heroku scheduler add-on"

namespace :emails do
  desc 'Send Pre Event emails'
  task :send_pre_event => :environment do
    Event.events_time("after_tomorrow").map{ |u| u.event_customer_participants }.flatten.each do |ecp|
      next if ecp.customer.email.blank? or !ecp.customer.send_event_related_emails? or ecp.event.store.email_setting.disable_event_reminder_email?
      current_time = Time.now.in_time_zone(ecp.event.store.time_zone)
      store_send_time = Time.parse("#{Date.today} #{ecp.event.store.email_setting.time_to_send_event_reminder}")
      if store_send_time > current_time.beginning_of_day
        SaleMailer.delay.email_event_confirmed_1daybefore_for_customer(ecp)
      end
    end
  end
end

namespace :rentals do
  desc 'Find all rentals with status booked and which started today and change status to in_progress'
  task change_to_in_progress: :environment do
    Rental.booked.find_each do |r|
      time = Time.now.in_time_zone(r.store.time_zone)
      r.to_in_progress! if r.pickup_date.to_datetime.beginning_of_day < time
    end
  end
end

namespace :sessions do
  desc 'Clear Sessions Table'
  task :clear_expired_sessions => :environment do
    ActiveRecord::SessionStore::Session.delete_all(["updated_at < ?", 2.weeks.ago])
  end
end
