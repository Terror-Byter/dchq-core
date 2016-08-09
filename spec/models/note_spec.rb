require 'spec_helper'

describe Note do
  context '#DB' do
    it { expect(subject).to have_db_index([:notable_type, :notable_id]) }
  end

  context '#Associations' do
    it { expect(subject).to belong_to(:notable) }
    it { expect(subject).to belong_to(:creator).class_name('User') }
    it { expect(subject).to have_one(:attachment).dependent(:destroy) }
  end

  context '#Nested Attributes' do
    it { expect(subject).to accept_nested_attributes_for(:attachment) }
  end

  context '#Validations' do
    it { expect(subject).to validate_presence_of(:creator).on(:update) }
    it { expect(subject).to validate_presence_of(:description) }
    it { expect(subject).to ensure_length_of(:description).is_at_most(65536) }
  end

  context '#Mass Assign Protection' do
    it { expect(subject).to allow_mass_assignment_of(:attachment_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:creator_id) }
    it { expect(subject).to allow_mass_assignment_of(:creator) }
    it { expect(subject).to allow_mass_assignment_of(:description) }
  end
end
