require 'spec_helper'

describe MiscellaneousProduct do
  context 'Indexes' do
    it { should have_db_index(:store_id) }
    it { should have_db_index(:category_id) }
    it { should have_db_index(:tax_rate_id) }
  end

  context 'Associations' do
    it { should belong_to(:store) }
    it { should belong_to(:category) }
    it { should belong_to(:tax_rate) }
    it { should have_one(:sale_product).dependent(:destroy) }
    it { should have_one(:sale).through(:sale_product) }
  end

  context 'Mass Assign Protection' do
    it { should allow_mass_assignment_of(:price) }
    it { should allow_mass_assignment_of(:tax_rate_id) }
    it { should allow_mass_assignment_of(:store_id) }
    it { should allow_mass_assignment_of(:category_id) }
    it { should allow_mass_assignment_of(:description) }
  end

  context 'Validations' do
    it { should validate_presence_of(:store) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:tax_rate) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
    it { expect(subject).to ensure_length_of(:description).is_at_most(65536) }
  end

  context '#Methods' do
    let(:store){ create(:store) }
    let(:category) { create(:category, store: store) }
    let(:tax_rate) { create(:tax_rate, store: store) }
    let(:miscellaneous_product){ create(:miscellaneous_product, store: store, category: category, tax_rate: tax_rate) }

    context '#class_type' do
      it 'should return class name' do
        expect(miscellaneous_product.class_type).to eq miscellaneous_product.class.name
      end
    end

    context '#logo' do
      it 'should return nil' do
        expect(miscellaneous_product.logo).to be_nil
      end
    end

    context '#name' do
      it 'should return name' do
        expect(miscellaneous_product.name).to eq I18n.t('models.miscellaneous_product.name')
      end
    end

    context '#unit_price' do
      let(:miscellaneous_product){ create(:miscellaneous_product, store: store, category: category, tax_rate: tax_rate, price: 75) }

      it 'should return unit_price' do
        expect(miscellaneous_product.unit_price).to eq 75
      end
    end

    context '#tax_rate_amount' do
      let(:tax_rate){ FactoryGirl.create(:tax_rate, store: store, amount: 12) }
      let(:miscellaneous_product){ create(:miscellaneous_product, store: store, category: category, tax_rate: tax_rate, price: 75) }

      it 'should return tax rate amount' do
        expect(miscellaneous_product.tax_rate_amount).to eq 12
      end
    end
  end
end
