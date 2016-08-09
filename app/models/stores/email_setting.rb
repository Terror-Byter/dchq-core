module Stores
  class EmailSetting < ActiveRecord::Base
    has_paper_trail

    belongs_to :store
    attr_accessible :booking_confirmed_content, :include_sale_receipt_to_booking_confirmed, :disable_booking_confirmed_email,
                    :event_reminder_content, :disable_event_reminder_email, :online_event_booking_content,
                    :include_sale_receipt_to_online_event_booking, :disable_online_event_booking_email, :sales_receipt_content,
                    :service_ready_for_collection_content, :include_sales_receipt_to_service_ready_for_collection,
                    :disable_service_ready_for_collection_email, :disable_low_inventory_product_reminder_email,
                    :time_to_send_event_reminder, :rental_receipt_content, :disable_rental_receipt_email, :language

    with_options allow_blank: true do |v|
      v.with_options length: { maximum: 65536 } do |o|
        o.validates :booking_confirmed_content
        o.validates :event_reminder_content
        o.validates :online_event_booking_content
        o.validates :sales_receipt_content
        o.validates :service_ready_for_collection_content
        o.validates :rental_receipt_content
      end
    end

    validates :time_to_send_event_reminder, timeliness: { type: :time }
  end
end
