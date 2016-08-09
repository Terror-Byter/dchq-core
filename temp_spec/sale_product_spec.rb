require 'spec_helper'

describe SaleProduct do
  before { mock_stripe }

  context 'DB index' do
    it { should have_db_index(:sale_id) }
    it { should have_db_index([:sale_productable_id, :sale_productable_type]) }
  end

  context 'Constants' do
    it { expect(SaleProduct::QUANTITY_LIMIT).to eq 99 }
  end

  context 'Associations' do
    it { should belong_to(:sale) }
    it { should belong_to(:sale_productable) }
    it { should belong_to(:product).class_name('Product') }
    it { should have_one(:prod_discount).class_name('Discount').dependent(:destroy) }
    it { should have_many(:refunded_sale_products).class_name('SaleProduct') }
    it { should have_many(:versions) }
  end

  context 'Nested Attributes' do
    it { should accept_nested_attributes_for(:prod_discount).allow_destroy(true) }
  end

  context 'Mass assing attributes' do
    it { should allow_mass_assignment_of(:sale_productable_type) }
    it { should allow_mass_assignment_of(:sale_productable_id) }
    it { should allow_mass_assignment_of(:quantity) }
    it { should allow_mass_assignment_of(:original_id) }
    it { should allow_mass_assignment_of(:prod_discount_attributes) }
    it { should allow_mass_assignment_of(:price) }
  end

  context 'Validations' do
    it { should validate_presence_of(:sale) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
  end

  context 'Scopes' do
  end

  context 'Methods' do
    context '#unit_price' do
      it 'should return product price for "product"' do
        sale_product = create(:sale_product_product)
        expect(sale_product.unit_price).to eq sale_product.sale_productable.unit_price
      end

      it 'should return freezing price for completed_sale if sale complete and freezing price is not null' do
        @sale = FactoryGirl.create(:completed_sale_with_sale_product_product)
        price = @sale.sale_products.first.sale_productable.unit_price
        @sale.freeze_product_prices
        Product.first.update_attributes(retail_price: 876.9)
        expect(@sale.sale_products.first.unit_price).to eq price
      end
    end

    context '#line_item_discount' do
      context 'if sale_productable_type is Product' do
        context 'If sale product has his own discount' do
          before do
            sale = FactoryGirl.create(:completed_sale_with_sale_product_product)
            @sp = sale.sale_products.first
          end

          it 'should return unit_price * quantity if discount is 100%' do
            @sp.create_prod_discount(value: 100, kind: 'percent')
            expect(@sp.line_item_discount).to eq @sp.unit_price * @sp.quantity
          end

          it 'should return unit_price if discount is equal unit_price * quantity' do
            @sp.create_prod_discount(value: @sp.unit_price * @sp.quantity, kind: 'USD')
            expect(@sp.line_item_discount).to eq @sp.unit_price * @sp.quantity
          end

          it 'should return unit_price * quantity - discount * quantity if discount in dolloars and lest then uniq_price' do
            sale = FactoryGirl.create(:completed_sale_with_static_sale_product_product)
            sp = sale.sale_products.first
            sp.create_prod_discount(value: 80, kind: 'USD')
            expect(sp.line_item_discount).to eq 80
          end

          it 'should return 0 if discount is not exist' do
            expect(@sp.line_item_discount).to eq 0
          end
        end

        context 'If sale has discount' do
          before do
            @sale = FactoryGirl.create(:completed_sale_with_sale_product_product)
            @sp = @sale.sale_products.first
          end

          it 'should return unit_price * quantity if discount is 100%' do
            @sale.create_discount(value: 100, kind: 'percent')
            expect(@sp.line_item_discount).to eq @sp.unit_price * @sp.quantity
          end

          it 'should return unit_price if discount is equal unit_price * quantity' do
            @sale.create_discount(value: @sp.unit_price * @sp.quantity, kind: 'USD')
            expect(@sp.line_item_discount).to eq @sp.unit_price * @sp.quantity
          end

          it 'should return unit_price * quantity - discount * quantity if discount in dolloars and lest then uniq_price' do
            sale = FactoryGirl.create(:completed_sale_with_static_sale_product_product)
            sp = sale.sale_products.first
            sale.create_discount(value: 80, kind: 'USD')
            expect(sp.line_item_discount).to eq 80
          end

          it 'should return 0 if discount is not exist' do
            expect(@sp.line_item_discount).to eq 0
          end
        end

      end
    end

    context '#line_item' do
      before do
        @sale_product = create(:static_sale_product_product)
      end

      it 'should return 450 if no discount' do
        expect(@sale_product.line_item).to eq 450
      end

      it 'should return 350 if local discount is exist in $' do
        @sale_product.create_prod_discount(value: 100, kind: 'USD')
        expect(@sale_product.line_item).to eq 350
      end

      it 'should return 225 if global discount in percent' do
        @sale_product.sale.create_discount(value: 50)
        expect(@sale_product.line_item).to eq 225
      end
    end

    context '#line_item_price' do
    end
  end
end
