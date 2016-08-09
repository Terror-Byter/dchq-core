require 'spec_helper'

describe RentalPayment do
  context '#DB' do
    it { expect(subject).to have_db_index(:rental_id) }
  end

  context '#Associations' do
    it { expect(subject).to belong_to(:rental) }
  end

  context '#Validation' do
    it { expect(subject).to validate_presence_of(:rental) }
  end

  context '#Mass Assign Protection' do
    it { expect(subject).to allow_mass_assignment_of(:rental) }
    it { expect(subject).to allow_mass_assignment_of(:rental_id) }
  end
end
