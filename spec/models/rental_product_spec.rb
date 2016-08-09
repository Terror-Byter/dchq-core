require 'spec_helper'

describe RentalProduct do
  context '#Associations' do
    it { expect(subject).to have_many(:renteds).dependent(:destroy) }
  end

  context '#Validations' do
    it { expect(subject).to validate_presence_of(:price_per_day) }
    it { expect(subject).to validate_numericality_of(:price_per_day).is_greater_than(0) }
  end

  context '#Methods' do
    let(:user){ create(:user) }
    let(:company){ user.company }
    let(:store){ company.stores.first }
    let(:category){ create(:category, store: store) }
    let(:supplier){ create(:supplier, company: company) }
    let(:brand){ create(:brand, store: store) }
    let(:rental_product){ create(:rental_product, store: store, supplier: supplier, brand: brand, category: category) }

    context '#archived!' do
      it 'should update archived field' do
        expect(rental_product.archived).to be_falsey
        rental_product.archived!
        expect(rental_product.archived).to be_truthy
      end
    end

    context '#unarchived!' do
      it 'should update unarchived field' do
        rental_product.archived!
        expect(rental_product.archived).to be_truthy
        rental_product.unarchived!
        expect(rental_product.archived).to be_falsey
      end
    end
  end
end
