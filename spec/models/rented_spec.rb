require 'spec_helper'

describe Rented do
  context '#DB' do
    it { expect(subject).to have_db_index(:rental_id) }
    it { expect(subject).to have_db_index(:rental_product_id) }
  end

  context '#Associations' do
    it { expect(subject).to belong_to(:rental) }
    it { expect(subject).to belong_to(:rental_product) }
    it { expect(subject).to have_one(:prod_discount).class_name('Discount').dependent(:destroy) }
  end

  context '#Validations' do
    it { expect(subject).to validate_presence_of(:rental) }
    it { expect(subject).to validate_presence_of(:rental_product) }
    it { expect(subject).to validate_presence_of(:quantity) }
    it { expect(subject).to validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
    it { expect(subject).to validate_presence_of(:item_amount) }
    it { expect(subject).to validate_numericality_of(:item_amount).is_greater_than_or_equal_to(0) }
    it { expect(subject).to validate_presence_of(:tax_rate) }
  end

  context '#Mass Assign Protection' do
    it { expect(subject).to allow_mass_assignment_of(:rental) }
    it { expect(subject).to allow_mass_assignment_of(:rental_id) }
    it { expect(subject).to allow_mass_assignment_of(:rental_product) }
    it { expect(subject).to allow_mass_assignment_of(:rental_product_id) }
    it { expect(subject).to allow_mass_assignment_of(:quantity) }
    it { expect(subject).to allow_mass_assignment_of(:item_amount) }
    it { expect(subject).to allow_mass_assignment_of(:tax_rate) }
    it { expect(subject).to allow_mass_assignment_of(:prod_discount_attributes) }
  end

  context '#Nested Attributes' do
    it { expect(subject).to accept_nested_attributes_for(:prod_discount) }
  end

  context '#Methods' do
    let(:user){ create(:user) }
    let(:company){ user.company }
    let(:store){ company.stores.first }
    let(:rental){ create(:empty_rental, store: store, user: user, customer: company.customers.first) }
    let(:brand){ create(:brand, store: store) }
    let(:category){ create(:category, store: store) }
    let(:supplier){ create(:supplier, company: company) }
    let(:rental_product){ create(:rental_product, brand: brand, category: category, supplier: supplier, store: store, tax_rate: store.tax_rates.first) }
    let(:rented){ create(:rented, rental_product: rental_product, rental: rental) }

    context '#check_rented_quantity' do
      it 'should not delete record' do
        rented.update_attributes quantity: 2
        expect(rented).to_not be_destroyed
      end

      it 'should be destroyed' do
        rented.update_attributes quantity: 0
        expect(rented).to be_destroyed
      end
    end

    context '#rented' do
      it 'should return item_amount' do
        expect(rented.unit_price).to eq rented.item_amount * 2
      end
    end

    context '#line_item' do
      let(:rented){ create(:rented, rental_product: rental_product, rental: rental, quantity: 4) }
      it 'should rentur value without discount' do
        expect(rented.line_item).to eq 800
      end
    end
  end
end
