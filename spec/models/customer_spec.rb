require 'spec_helper'

describe Customer do
  context '#DB' do
    it { expect(subject).to have_db_index(:company_id) }
    it { expect(subject).to have_db_index(:customer_experience_level_id) }
  end

  context '#Associations' do
    it { expect(subject).to have_one(:address) }
    it { expect(subject).to have_one(:avatar) }
    it { expect(subject).to have_many(:certification_level_memberships) }
    it { expect(subject).to have_many(:incidents) }
    it { expect(subject).to have_many(:notes) }
    it { expect(subject).to have_many(:sale_customers) }
    it { expect(subject).to have_many(:sales).through(:sale_customers) }
    it { expect(subject).to have_many(:event_customer_participants) }
    it { expect(subject).to have_many(:credit_notes) }
    it { expect(subject).to have_many(:custom_fields).class_name('Stores::CustomField') }
    it { expect(subject).to have_many(:services) }
    it { expect(subject).to have_many(:events).through(:event_customer_participants) }
    it { expect(subject).to have_many(:rentals) }
  end

  context '#Nested Attributes' do
    it { expect(subject).to accept_nested_attributes_for(:address) }
    it { expect(subject).to accept_nested_attributes_for(:avatar) }
    it { expect(subject).to accept_nested_attributes_for(:certification_level_memberships) }
    it { expect(subject).to accept_nested_attributes_for(:custom_fields) }
    it { expect(subject).to accept_nested_attributes_for(:notes) }
  end

  context '#Mass Assigned Protection' do
    it { expect(subject).to allow_mass_assignment_of(:address_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:avatar_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:certification_level_memberships_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:company_id) }
    it { expect(subject).to allow_mass_assignment_of(:customer_experience_level_id) }
    it { expect(subject).to allow_mass_assignment_of(:given_name) }
    it { expect(subject).to allow_mass_assignment_of(:family_name) }
    it { expect(subject).to allow_mass_assignment_of(:born_on) }
    it { expect(subject).to allow_mass_assignment_of(:default_discount_level) }
    it { expect(subject).to allow_mass_assignment_of(:source) }
    it { expect(subject).to allow_mass_assignment_of(:telephone) }
    it { expect(subject).to allow_mass_assignment_of(:mobile_phone) }
    it { expect(subject).to allow_mass_assignment_of(:email) }
    it { expect(subject).to allow_mass_assignment_of(:fins) }
    it { expect(subject).to allow_mass_assignment_of(:bcd) }
    it { expect(subject).to allow_mass_assignment_of(:wetsuit) }
    it { expect(subject).to allow_mass_assignment_of(:last_dive_on) }
    it { expect(subject).to allow_mass_assignment_of(:number_of_logged_dives) }
    it { expect(subject).to allow_mass_assignment_of(:tag_list) }
    it { expect(subject).to allow_mass_assignment_of(:hotel_name) }
    it { expect(subject).to allow_mass_assignment_of(:room_number) }
    it { expect(subject).to allow_mass_assignment_of(:gender) }
    it { expect(subject).to allow_mass_assignment_of(:credit_note) }
    it { expect(subject).to allow_mass_assignment_of(:emergency_contact_details) }
    it { expect(subject).to allow_mass_assignment_of(:weight) }
    it { expect(subject).to allow_mass_assignment_of(:fins_own) }
    it { expect(subject).to allow_mass_assignment_of(:bcd_own) }
    it { expect(subject).to allow_mass_assignment_of(:wetsuit_own) }
    it { expect(subject).to allow_mass_assignment_of(:mask_own) }
    it { expect(subject).to allow_mass_assignment_of(:regulator_own) }
    it { expect(subject).to allow_mass_assignment_of(:custom_fields_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:notes_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:send_event_related_emails) }
    it { expect(subject).to allow_mass_assignment_of(:tax_id) }
    it { expect(subject).to allow_mass_assignment_of(:zero_tax_rate) }
    it { expect(subject).to allow_mass_assignment_of(:booked) }
    it { expect(subject).to allow_mass_assignment_of(:deleted_at) }
  end
end
