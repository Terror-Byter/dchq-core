require 'spec_helper'

describe CommissionRate do
  context '#DB' do
    it { expect(subject).to have_db_index(:store_id) }
  end

  context '#Associations' do
    it { expect(subject).to belong_to(:store)  }
  end

  context '#Validations' do
    it { expect(subject).to validate_presence_of(:store_id) }
    it { expect(subject).to validate_presence_of(:amount) }
    it { expect(subject).to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { expect(subject).to validate_numericality_of(:amount).is_less_than_or_equal_to(100) }
    it { expect(subject).to validate_uniqueness_of(:amount).scoped_to(:store_id) }
  end

  context '#Mass Assing Attributes' do
    it { expect(subject).to allow_mass_assignment_of(:amount) }
  end

  describe '#Methods' do
    let(:store) { create(:store) }

    context '#default?' do
      it 'should return true' do
        store
        expect(CommissionRate.first.default?).to be_truthy
      end

      it 'should return false' do
        pending 'need to fix'
        commission_rate = store.commission_rates.create( amount: 15 )
        expect(commission_rate.default?).to be_falsey
      end
    end

    context '#formatted_amount' do
      it 'should return formatted string' do
        commission_rate = store.commission_rates.create amount: 9
        expect(commission_rate.formatted_amount).to eq('9.0%')
      end
    end
  end
end
