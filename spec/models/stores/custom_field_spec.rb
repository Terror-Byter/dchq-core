require 'spec_helper'

describe Stores::CustomField do
  context '#DB' do
    it { expect(subject).to have_db_index(:customer_id) }
  end

  context '#Associations' do
    it { expect(subject).to belong_to(:customer) }
  end

  context '#Mass Assign Protection' do
    it { expect(subject).to allow_mass_assignment_of(:name) }
    it { expect(subject).to allow_mass_assignment_of(:value) }
  end

  context '#Validations' do
    it { expect(subject).to validate_presence_of(:name) }
    it { expect(subject).to ensure_length_of(:name).is_at_most(255) }
    it { expect(subject).to ensure_length_of(:value).is_at_most(255) }
  end
end
