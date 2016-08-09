require 'spec_helper'

describe StoreProduct do
  context '#DB' do
    it { expect(subject).to have_db_index(:store_id) }
    it { expect(subject).to have_db_index(:category_id) }
    it { expect(subject).to have_db_index(:brand_id) }
    it { expect(subject).to have_db_index(:supplier_id) }
    it { expect(subject).to have_db_index(:tax_rate_id) }
    it { expect(subject).to have_db_index(:commission_rate_id) }
  end

  context '#Associations' do
    it { expect(subject).to belong_to :store }
    it { expect(subject).to belong_to :category }
    it { expect(subject).to belong_to :brand }
    it { expect(subject).to belong_to :supplier }
    it { expect(subject).to belong_to :tax_rate }
    it { expect(subject).to belong_to :commission_rate }
    it { expect(subject).to have_one(:logo).class_name('Image').dependent(:destroy) }
  end

  context '#Nested Attributes' do
    it { expect(subject).to accept_nested_attributes_for(:logo) }
  end

  context '#Validations' do
    it { expect(subject).to validate_presence_of(:store) }
    it { expect(subject).to validate_presence_of(:category) }
    it { expect(subject).to validate_presence_of(:brand) }
    it { expect(subject).to validate_presence_of(:supplier) }
    it { expect(subject).to validate_presence_of(:tax_rate) }
    it { expect(subject).to validate_presence_of(:name) }
    it { expect(subject).to ensure_length_of(:name).is_at_most(255) }
    it { expect(subject).to validate_presence_of(:sku_code) }
    it { expect(subject).to validate_uniqueness_of(:sku_code).scoped_to(:store_id) }
    it { expect(subject).to validate_numericality_of(:number_in_stock).is_less_than(99999) }
  end

  context '#Mass Assigned Protection' do
    it { expect(subject).to allow_mass_assignment_of(:store_id) }
    it { expect(subject).to allow_mass_assignment_of(:store) }
    it { expect(subject).to allow_mass_assignment_of(:category_id) }
    it { expect(subject).to allow_mass_assignment_of(:category) }
    it { expect(subject).to allow_mass_assignment_of(:brand_id) }
    it { expect(subject).to allow_mass_assignment_of(:brand) }
    it { expect(subject).to allow_mass_assignment_of(:supplier_id) }
    it { expect(subject).to allow_mass_assignment_of(:supplier) }
    it { expect(subject).to allow_mass_assignment_of(:tax_rate_id) }
    it { expect(subject).to allow_mass_assignment_of(:tax_rate) }
    it { expect(subject).to allow_mass_assignment_of(:commission_rate_id) }
    it { expect(subject).to allow_mass_assignment_of(:commission_rate) }
    it { expect(subject).to allow_mass_assignment_of(:name) }
    it { expect(subject).to allow_mass_assignment_of(:sku_code) }
    it { expect(subject).to allow_mass_assignment_of(:number_in_stock) }
    it { expect(subject).to allow_mass_assignment_of(:description) }
    it { expect(subject).to allow_mass_assignment_of(:accounting_code) }
    it { expect(subject).to allow_mass_assignment_of(:supplier_code) }
    it { expect(subject).to allow_mass_assignment_of(:supply_price) }
    it { expect(subject).to allow_mass_assignment_of(:retail_price) }
    it { expect(subject).to allow_mass_assignment_of(:commission_rate_money) }
    it { expect(subject).to allow_mass_assignment_of(:markup) }
    it { expect(subject).to allow_mass_assignment_of(:barcode) }
    it { expect(subject).to allow_mass_assignment_of(:low_inventory_reminder) }
    it { expect(subject).to allow_mass_assignment_of(:sent_at) }
    it { expect(subject).to allow_mass_assignment_of(:offer_price) }
    it { expect(subject).to allow_mass_assignment_of(:archived) }
    it { expect(subject).to allow_mass_assignment_of(:price_per_day) }
    it { expect(subject).to allow_mass_assignment_of(:logo_attributes) }
  end
end
