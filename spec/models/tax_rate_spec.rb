require 'spec_helper'

describe TaxRate do
  context '#DB' do
    it { expect(subject).to have_db_index(:store_id) }
  end

  context 'Associations' do
    it { expect(subject).to belong_to(:store) }
    it { expect(subject).to have_many(:service_kits).class_name('Services::ServiceKit') }
    it { expect(subject).to have_many(:products) }
    it { expect(subject).to have_many(:miscellaneous_products) }
    it { expect(subject).to have_many(:sale_products).through(:products) }
    it { expect(subject).to have_many(:kit_hires).class_name('ExtraEvents::KitHire') }
    it { expect(subject).to have_many(:transports).class_name('ExtraEvents::Transport') }
    it { expect(subject).to have_many(:insurances).class_name('ExtraEvents::Insurance') }
    it { expect(subject).to have_many(:additionals).class_name('ExtraEvents::Additional') }
  end

  context 'Validations' do
    it { expect(subject).to validate_presence_of(:store_id) }
    it { expect(subject).to validate_presence_of(:amount) }
    it { expect(subject).to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { expect(subject).to validate_numericality_of(:amount).is_less_than_or_equal_to(100) }
    it { expect(subject).to validate_uniqueness_of(:amount).scoped_to(:store_id) }
    it { expect(subject).to ensure_length_of(:identifier).is_at_most(255) }
    it { expect(subject).to allow_value('', nil).for(:identifier) }
  end

  context 'Mass Assing Attributes' do
    it { expect(subject).to allow_mass_assignment_of(:amount) }
    it { expect(subject).to allow_mass_assignment_of(:identifier) }
  end

  describe 'methods' do
    let(:store){ create(:store) }

    context '#default?' do
      it 'should return true' do
        store
        expect(TaxRate.first.default?).to be_truthy
      end

      it 'should return false' do
        tax_rate = store.tax_rates.create( amount: 0 )
        expect(tax_rate.default?).to be_falsey
      end
    end

    context '#withdrawal_coef' do
      it 'should return number' do
        tax_rate = store.tax_rates.create amount: 6
        expect(tax_rate.withdrawal_coef).to eq 0.94
      end
    end

    context '#formatted_amount' do
      it 'should return formatted string' do
        tax_rate = store.tax_rates.create amount: 9
        expect(tax_rate.formatted_amount).to eq '9.0%'
      end
    end

    context '#check_that_tax_has_no_products' do
      it 'should return false' do
        pending 'ss'
        product = FactoryGirl.create(:product)
        product.tax_rate.destroy
        expect(product.tax_rate.blank?).to be_falsey
      end

      it 'should delete tax_rate' do
        pending 'ss'
        tax_rate = create(:tax_rate, store: @store)
        tax_rate.destroy
        expect(TaxRate.find_by_id(tax_rate.id)).to be_nil
      end
    end
  end
end
