require 'spec_helper'

describe OtherEvent do
  context '#DB' do
    it { expect(subject).to have_db_index(:event_trip_id) }
    it { expect(subject).to have_db_index(:parent_id) }
  end

  context '#Associations' do
    it { expect(subject).to belong_to(:event_trip) }
    it { expect(subject).to belong_to(:parent).class_name('OtherEvent') }
  end

  context '#Mass Assign Protection' do
    it { expect(subject).to allow_mass_assignment_of(:name) }
    it { expect(subject).to allow_mass_assignment_of(:event_type_id) }
    it { expect(subject).to allow_mass_assignment_of(:event_trip_id) }
    it { expect(subject).to allow_mass_assignment_of(:starts_at) }
    it { expect(subject).to allow_mass_assignment_of(:ends_at) }
    it { expect(subject).to allow_mass_assignment_of(:frequency) }
    it { expect(subject).to allow_mass_assignment_of(:boat_id) }
    it { expect(subject).to allow_mass_assignment_of(:location) }
    it { expect(subject).to allow_mass_assignment_of(:number_of_dives) }
    it { expect(subject).to allow_mass_assignment_of(:limit_of_registrations) }
    it { expect(subject).to allow_mass_assignment_of(:price) }
    it { expect(subject).to allow_mass_assignment_of(:instructions) }
    it { expect(subject).to allow_mass_assignment_of(:notes) }
    it { expect(subject).to allow_mass_assignment_of(:additional_equipment) }
    it { expect(subject).to allow_mass_assignment_of(:private) }
    it { expect(subject).to allow_mass_assignment_of(:enable_booking) }
    it { expect(subject).to allow_mass_assignment_of(:number_of_recurring_events_for_update) }
    it { expect(subject).to allow_mass_assignment_of(:number_of_frequencies) }
  end

  context '#Validations' do
    it { expect(subject).to ensure_length_of(:name).is_at_most(255) }
    it { expect(subject).to allow_value('', nil).for(:name) }
    it { expect(subject).to validate_numericality_of(:number_of_frequencies).is_greater_than_or_equal_to(0) }
  end
end
