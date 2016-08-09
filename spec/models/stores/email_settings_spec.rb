require 'spec_helper'

describe Stores::EmailSetting do
  context '#DB' do
    it { expect(subject).to have_db_index(:store_id) }
  end

  context '#Associations' do
    it { expect(subject).to belong_to(:store) }
  end

  context '#Mass Assigned Protection' do
    it { expect(subject).to allow_mass_assignment_of(:booking_confirmed_content) }
    it { expect(subject).to allow_mass_assignment_of(:include_sale_receipt_to_booking_confirmed) }
    it { expect(subject).to allow_mass_assignment_of(:disable_booking_confirmed_email) }
    it { expect(subject).to allow_mass_assignment_of(:event_reminder_content) }
    it { expect(subject).to allow_mass_assignment_of(:disable_event_reminder_email) }
    it { expect(subject).to allow_mass_assignment_of(:online_event_booking_content) }
    it { expect(subject).to allow_mass_assignment_of(:include_sale_receipt_to_online_event_booking) }
    it { expect(subject).to allow_mass_assignment_of(:disable_online_event_booking_email) }
    it { expect(subject).to allow_mass_assignment_of(:sales_receipt_content) }
    it { expect(subject).to allow_mass_assignment_of(:service_ready_for_collection_content) }
    it { expect(subject).to allow_mass_assignment_of(:include_sales_receipt_to_service_ready_for_collection) }
    it { expect(subject).to allow_mass_assignment_of(:disable_service_ready_for_collection_email) }
    it { expect(subject).to allow_mass_assignment_of(:disable_low_inventory_product_reminder_email) }
    it { expect(subject).to allow_mass_assignment_of(:time_to_send_event_reminder) }
    it { expect(subject).to allow_mass_assignment_of(:rental_receipt_content) }
    it { expect(subject).to allow_mass_assignment_of(:disable_rental_receipt_email) }
  end

  context '#Validations' do
    it { expect(subject).to ensure_length_of(:booking_confirmed_content).is_at_most(65536) }
    it { expect(subject).to allow_value('', nil).for(:booking_confirmed_content) }
    it { expect(subject).to ensure_length_of(:event_reminder_content).is_at_most(65536) }
    it { expect(subject).to allow_value('', nil).for(:event_reminder_content) }
    it { expect(subject).to ensure_length_of(:online_event_booking_content).is_at_most(65536) }
    it { expect(subject).to allow_value('', nil).for(:online_event_booking_content) }
    it { expect(subject).to ensure_length_of(:sales_receipt_content).is_at_most(65536) }
    it { expect(subject).to allow_value('', nil).for(:sales_receipt_content) }
    it { expect(subject).to ensure_length_of(:service_ready_for_collection_content).is_at_most(65536) }
    it { expect(subject).to allow_value('', nil).for(:service_ready_for_collection_content) }
    it { expect(subject).to ensure_length_of(:rental_receipt_content).is_at_most(65536) }
    it { expect(subject).to allow_value('', nil).for(:rental_receipt_content) }
  end
end
