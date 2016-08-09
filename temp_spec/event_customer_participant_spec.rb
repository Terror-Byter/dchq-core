require 'spec_helper'

describe EventCustomerParticipant do
  context 'DB' do
    it { should have_db_index(:event_id) }
    it { should have_db_index(:customer_id) }
    it { should have_db_index(:event_user_participant_id) }
    it { should have_db_index(:sale_id) }
    it { should have_db_index(:original_id) }
  end

  context 'Constant' do
    it 'should has EVENT_TYPES' do
      expect(EventCustomerParticipant::EVENT_TYPES).to eq [:transports, :additionals, :kit_hire, :insurance]
    end
  end

  context 'Associations' do
    it { should have_many(:event_customer_participant_options).dependent(:destroy).class_name('EventCustomerParticipantOptions::EventCustomerParticipantOption') }
    it { should have_one(:event_customer_participant_insurance).class_name('EventCustomerParticipantOptions::Insurance') }
    it { should have_one(:event_customer_participant_kit_hire).class_name('EventCustomerParticipantOptions::KitHire') }
    it { should have_many(:event_customer_participant_additionals).class_name('EventCustomerParticipantOptions::Additional') }
    it { should have_many(:event_customer_participant_transports).class_name('EventCustomerParticipantOptions::Transport') }
    it { should have_one(:event_customer_participant_discount).class_name('Discount').dependent('destroy') }
    it { should have_many(:transports).through(:event_customer_participant_transports) }
    it { should have_many(:additionals).through(:event_customer_participant_additionals) }
    it { should have_one(:kit_hire).through(:event_customer_participant_kit_hire) }
    it { should have_one(:insurance).through(:event_customer_participant_insurance) }
    it { should belong_to(:event) }
    it { should belong_to(:customer) }
    it { should belong_to(:event_user_participant) }
    it { should belong_to(:sale) }
    it { should belong_to(:original).class_name('EventCustomerParticipant') }
    it { should have_many(:refunded).class_name('EventCustomerParticipant') }
  end

  context 'NestedAttributes' do
    it { should accept_nested_attributes_for(:event_customer_participant_transports).allow_destroy(true) }
    it { should accept_nested_attributes_for(:event_customer_participant_additionals).allow_destroy(true) }
    it { should accept_nested_attributes_for(:event_customer_participant_kit_hire).allow_destroy(true) }
    it { should accept_nested_attributes_for(:event_customer_participant_insurance).allow_destroy(true) }
    it { should accept_nested_attributes_for(:event_customer_participant_discount).allow_destroy(true) }
  end

  context 'Validations' do
    it { should validate_presence_of(:event) }
    it { should validate_presence_of(:customer_id) }
    it { should validate_uniqueness_of(:customer_id).scoped_to([:event_id, :original_id]).with_message(/has already been added to this event/) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0.0) }
    it { should validate_numericality_of(:nitrox).is_greater_than_or_equal_to(0) }
  end

  context 'Allow Mass Assign Protection' do
    it { should allow_mass_assignment_of(:local_event) }
    it { should allow_mass_assignment_of(:event_id) }
    it { should allow_mass_assignment_of(:event_user_participant_id) }
    it { should allow_mass_assignment_of(:event_customer_participant_kit_hire_attributes) }
    it { should allow_mass_assignment_of(:event_customer_participant_insurance_attributes) }
    it { should allow_mass_assignment_of(:nitrox) }
    it { should allow_mass_assignment_of(:event_customer_participant_transports_attributes) }
    it { should allow_mass_assignment_of(:event_customer_participant_additionals_attributes) }
    it { should allow_mass_assignment_of(:customer_id) }
    it { should allow_mass_assignment_of(:sale_id) }
    it { should allow_mass_assignment_of(:event_customer_participant_discount_attributes) }
    it { should allow_mass_assignment_of(:price) }
    it { should allow_mass_assignment_of(:original_id) }
  end

  context '#Methods' do
    context '#unpaid?' do
      let(:store){ create(:store) }
      let(:tax_rate) { create(:tax_rate, amount: 10, store: store) }
      let(:event_trip){ create(:event_trip, store: store, tax_rate: tax_rate) }
      let(:other_event){ create(:other_event, event_trip: event_trip, store: store) }
      let(:ecp){ create(:event_customer_participant, event: other_event, sale: nil) }

      it "should return true" do
        expect(ecp.unpaid?).to be_true
      end

      it "should return false" do
        ecp.update_attributes sale_id: FactoryGirl.create(:full_sale, store: store).id
        ecp.reload
        expect(ecp.unpaid?).to be_false
      end
    end
  end
end
