require 'spec_helper'

describe Till do
  context '#DB' do
    it { expect(subject).to have_db_index(:store_id) }
    it { expect(subject).to have_db_index(:user_id) }
  end

  context '#Associations' do
    it { expect(subject).to belong_to(:store) }
    it { expect(subject).to belong_to(:user) }
  end

  context '#Mass Assigned Protection' do
    it { expect(subject).to allow_mass_assignment_of(:store_id) }
    it { expect(subject).to allow_mass_assignment_of(:store) }
    it { expect(subject).to allow_mass_assignment_of(:user_id) }
    it { expect(subject).to allow_mass_assignment_of(:user) }
    it { expect(subject).to allow_mass_assignment_of(:amount) }
    it { expect(subject).to allow_mass_assignment_of(:notes) }
    it { expect(subject).to allow_mass_assignment_of(:take_out) }
  end

  context '#Validations' do
    it { expect(subject).to validate_presence_of(:store) }
    it { expect(subject).to validate_presence_of(:user) }
    it { expect(subject).to ensure_length_of(:notes).is_at_most(65536) }
    #it { expect(subject).to ensure_inclusion_of(:take_out).in_array([true, false]) }
  end
end
