require 'spec_helper'

describe Rental do
  context '#DB' do
    it { expect(subject).to have_db_index(:user_id) }
    it { expect(subject).to have_db_index(:customer_id) }
    it { expect(subject).to have_db_index(:store_id) }
  end

  context '#Associations' do
    it { expect(subject).to belong_to(:user) }
    it { expect(subject).to belong_to(:customer) }
    it { expect(subject).to belong_to(:store) }
    it { expect(subject).to have_many(:renteds).dependent(:destroy) }
    it { expect(subject).to have_many(:rental_payments).dependent(:destroy) }
  end

  context '#Validations' do
    it { expect(subject).to validate_presence_of(:user) }
    it { expect(subject).to validate_presence_of(:store) }
    it { expect(subject).to validate_presence_of(:customer) }
    it { expect(subject).to validate_presence_of(:pickup_date) }
    it { expect(subject).to validate_presence_of(:return_date) }
    it { expect(subject).to validate_presence_of(:amount) }
    it { expect(subject).to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { expect(subject).to ensure_length_of(:note).is_at_most(65536) }
    it { expect(subject).to validate_presence_of(:grand_total) }
    it { expect(subject).to validate_numericality_of(:grand_total) }
    it { expect(subject).to validate_presence_of(:change) }
    it { expect(subject).to validate_numericality_of(:change) }
  end

  context '#Nested Attributes' do
    it { expect(subject).to accept_nested_attributes_for(:renteds) }
    it { expect(subject).to accept_nested_attributes_for(:rental_payments) }
  end

  context '#Mass Assign Protection' do
    it { expect(subject).to allow_mass_assignment_of(:user_id) }
    it { expect(subject).to allow_mass_assignment_of(:user) }
    it { expect(subject).to allow_mass_assignment_of(:store_id) }
    it { expect(subject).to allow_mass_assignment_of(:store) }
    it { expect(subject).to allow_mass_assignment_of(:customer_id) }
    it { expect(subject).to allow_mass_assignment_of(:customer) }
    it { expect(subject).to allow_mass_assignment_of(:status) }
    it { expect(subject).to allow_mass_assignment_of(:pickup_date) }
    it { expect(subject).to allow_mass_assignment_of(:return_date) }
    it { expect(subject).to allow_mass_assignment_of(:renteds_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:note) }
    it { expect(subject).to allow_mass_assignment_of(:grand_total) }
    it { expect(subject).to allow_mass_assignment_of(:change) }
    it { expect(subject).to allow_mass_assignment_of(:rental_payments_attributes) }
  end

  let(:user){ create(:user) }
  let(:company){ user.company }
  let(:store){ company.stores.first }
  let(:empty_rental){ create(:empty_rental, store: store, user: user, customer: company.customers.first) }
  let(:rental){ create(:rental, store: store, user: user, customer: company.customers.first) }
  let(:category){ create(:category, store: store) }
  let(:brand){ create(:brand, store: store) }
  let(:supplier){ create(:supplier, company: company) }
  let(:rental_product){ create(:rental_product, store: store, category: category, brand: brand, supplier: supplier) }
  let(:rented){ create(:rented, rental: rental, rental_product: rental_product) }
  let(:rental_payment){ create(:rental_payment, rental: rental, amount: 50, payment_method: store.payment_methods.first, cashier: user) }

  context '#States' do
    context 'Pay Pending' do
      it 'should has status lpay pending by default' do
        expect(empty_rental).to be_pay_pending
      end

      it 'should be able change status to booked' do
        expect(empty_rental).to be_may_to_booked
      end

      it 'should not be able change status to in_progress' do
        expect(empty_rental).to_not be_may_to_in_progress
      end

      it 'should not be able change status to overdue' do
        expect(empty_rental).to_not be_may_to_overdue
      end

      it 'should not be able change status to complete' do
        expect(empty_rental).to_not be_may_to_complete
      end
    end

    context 'Booked' do
      before { empty_rental.to_booked }

      it 'should not has status pay_pending' do
        expect(empty_rental).to_not be_pay_pending
      end

      it 'should has status booked' do
        expect(empty_rental).to be_booked
      end

      it 'should be able change status to in_progress' do
        expect(empty_rental).to be_may_to_in_progress
      end

      it 'should not be able change status to overdue' do
        expect(empty_rental).to_not be_may_to_overdue
      end

      it 'should not be able change status to complete' do
        expect(empty_rental).to_not be_may_to_complete
      end
    end

    context 'In Progress' do
      before {
        empty_rental.to_booked
        empty_rental.to_in_progress
      }

      it 'should not has status booked' do
        expect(empty_rental).to_not be_booked
      end

      it 'should not has status pay_pending' do
        expect(empty_rental).to_not be_pay_pending
      end

      it 'should has status in_progress' do
        expect(empty_rental).to be_in_progress
      end

      it 'should be able change status to overdue' do
        expect(empty_rental).to be_may_to_overdue
      end

      it 'should be able change status to complete' do
        expect(empty_rental).to be_may_to_complete
      end

      it 'should not be able change status to booked' do
        expect(empty_rental).to_not be_may_to_booked
      end
    end

    context 'Overdue' do
      before {
        empty_rental.to_booked
        empty_rental.to_in_progress
        empty_rental.to_overdue
      }

      it 'should not has status booked' do
        expect(empty_rental).to_not be_booked
      end

      it 'should not has status pay_pending' do
        expect(empty_rental).to_not be_pay_pending
      end

      it 'should not has status in_progress' do
        expect(empty_rental).to_not be_in_progress
      end

      it 'should has status in_progress' do
        expect(empty_rental).to be_overdue
      end

      it 'should be able change status to complete' do
        expect(empty_rental).to be_may_to_complete
      end

      it 'should not be able change status to booked' do
        expect(empty_rental).to_not be_may_to_booked
      end

      it 'should not be able change status to in_progress' do
        expect(empty_rental).to_not be_may_to_in_progress
      end
    end

    context 'Complete' do
      before {
        empty_rental.to_booked
        empty_rental.to_in_progress
        empty_rental.to_complete
      }

      it 'should not has status booked' do
        expect(empty_rental).to_not be_booked
      end

      it 'should not has status pay_pending' do
        expect(empty_rental).to_not be_pay_pending
      end

      it 'should not has status in_progress' do
        expect(empty_rental).to_not be_in_progress
      end

      it 'should not has status in_overdue' do
        expect(empty_rental).to_not be_overdue
      end

      it 'should has status complete' do
        expect(empty_rental).to be_complete
      end

      it 'should_not be able change status to overdue' do
        expect(empty_rental).to_not be_may_to_overdue
      end

      it 'should_not be able change status to booked' do
        expect(empty_rental).to_not be_may_to_booked
      end

      it 'should not be able change status to in_progress' do
        expect(empty_rental).to_not be_may_to_in_progress
      end
    end
  end

  context '#Methods' do
    context '#days' do
      it 'should return number of days for rental' do
        expect(empty_rental.days).to eq 2
      end
    end

    context '#layby' do
      it 'should return true' do
        expect(empty_rental.layby?).to be_truthy
      end

      it 'should return false' do
        rental
        rented
        rental_payment
        expect(rental.layby?).to be_falsey
      end
    end

    context '#calc_grand_total' do
      context 'without_discount and tax rate inclusion' do
        it 'should be equal' do
          rental
          rented
          rental_payment
          expect(rental.calc_grand_total).to eq 200
        end
      end
    end
  end
end
