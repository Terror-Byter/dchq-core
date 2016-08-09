require 'spec_helper'

describe RentalProductDecorator do
  let(:user){ create(:user) }
  let(:company){ user.company }
  let(:store){ company.stores.first }
  let(:category){ create(:category, store: store) }
  let(:supplier){ create(:supplier, company: company) }
  let(:brand){ create(:brand, store: store) }
  let(:rental_product){ create(:rental_product, store: store, supplier: supplier, brand: brand, category: category) }

  let(:decorator){ RentalProductDecorator.decorate(rental_product) }

  context '#brand_name' do
    it 'should return brand_name' do
      expect(decorator.brand_name).to eq brand.name
    end
  end

  context '#category_name' do
    it 'should return category_name' do
      expect(decorator.category_name).to eq category.name
    end
  end

  context '#supplier_name' do
    it 'should return supplier_name' do
      expect(decorator.supplier_name).to eq supplier.name
    end
  end

  context '#no_commission_rate?' do
    it 'should return false' do
      expect(decorator.no_commission_rate?).to be_falsey
    end

    it 'should return true' do
      rental_product = create(:rental_product, store: store, supplier: supplier, brand: brand, category: category, commission_rate_money: 10, commission_rate: nil)
      decorator = RentalProductDecorator.decorate(rental_product)
      expect(decorator.no_commission_rate?).to be_truthy
    end
  end

  context '#commission_rate' do
    it 'should return formatted_amount for comission rate' do
      expect(decorator.commission_rate).to eq rental_product.commission_rate.formatted_amount
    end
  end

  context '#tax_rate' do
    it 'should return formatted_amount for tax rate' do
      expect(decorator.tax_rate).to eq rental_product.tax_rate.formatted_amount
    end
  end
end
