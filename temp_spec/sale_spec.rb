require 'spec_helper'

describe Sale do
  before { mock_stripe }

  context 'Associations' do
    it { should belong_to(:store) }
    it { should belong_to(:creator).class_name('User') }
    it { should belong_to(:parent).class_name('Sale').with_foreign_key('parent_id') }
    it { should have_one(:company).through(:store) }
    it { should have_many(:children).class_name('Sale').with_foreign_key('parent_id') }
    it { should have_many(:customers).through(:sale_customers) }
    it { should have_many(:products).through(:sale_products) }  #
    it { should have_many(:event_customer_participants) } #
    it { should have_many(:events).through(:event_customer_participants) }

    it { should have_one(:discount).dependent(:destroy) }
    it { should have_many(:sale_products).dependent(:destroy) }
    it { should have_many(:sale_customers).dependent(:destroy) }
    it { should have_many(:payments).dependent(:destroy) }
    it { should have_many(:credit_notes).dependent(:destroy) }
  end

  context 'Accepts Nested Attributes' do
    it { should accept_nested_attributes_for(:discount).allow_destroy(true) }
    it { should accept_nested_attributes_for(:sale_products).allow_destroy(true) }
    it { should accept_nested_attributes_for(:payments) } #
  end

  context 'Validations' do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:grand_total) }
    it { should validate_presence_of(:change) }

    it {should ensure_inclusion_of(:status).in_array(Sale::STATUSES.keys) }

    it { should validate_numericality_of(:grand_total) }
    it { should validate_numericality_of(:change) }
  end

  context 'Allow Mass Assigned Attributes' do
    it { should allow_mass_assignment_of(:creator) }
    it { should allow_mass_assignment_of(:creator_id) }
    it { should allow_mass_assignment_of(:sale_products_attributes) }
    it { should allow_mass_assignment_of(:event_customer_participants_attributes) }
    it { should allow_mass_assignment_of(:status) }
    it { should allow_mass_assignment_of(:payments_attributes) }
    it { should allow_mass_assignment_of(:store_id) }
    it { should allow_mass_assignment_of(:booking) }
    it { should allow_mass_assignment_of(:parent_id) }
    it { should allow_mass_assignment_of(:discount_attributes) }
  end

  describe 'Default Values' do
    let(:sale){ create(:full_sale) }

    context 'status' do
      it 'is active' do
        sale.status.should eq('active')
      end
    end

    context 'booking' do
      it 'is false' do
        sale.booking.should eq(false)
      end
    end
  end

  describe 'Methods' do
    context "update_status!" do
      it "changes status on active" do
        sale = create(:full_sale, status: 'layby')
        expect{ sale.update_status! }.to change{sale.status}.from('layby').to('active')
      end

      it "changes status on layby" do
        sale = create(:sale_with_payment, status: "active")
        expect{ sale.update_status! }.not_to change{sale.status}
      end

      it "not changes status if status is refund" do
        sale = create(:full_sale, status: 'refund')
        expect{ sale.update_status! }.not_to change{sale.status}
      end
    end

    context "remove_event_customer_participants!" do
      it "destroy all event customer participants if status is refund" do
        sale = create(:sale_with_event_customer_participant, status: 'refund')
        sale.event_customer_participants.count.should eq(1)
        expect{ sale.remove_event_customer_participants! }.to change{sale.event_customer_participants.count}.by(-1)
      end

      it "changes event_customer_participants's sale_id to nil" do
        sale = create(:sale_with_event_customer_participant)
        sale.event_customer_participants.count.should eq(1)
        expect{ sale.remove_event_customer_participants! }.to change{sale.event_customer_participants.count}.by(-1)
      end
    end

    context "cost_of_goods" do
      let(:sale){ create(:full_sale) }
      let(:product){ create(:product, store: sale.store, supply_price: 10) }

      it "calculates sum of supply_price of all sale_products with type products" do
        sale_product_product = create(:sale_product, sale_productable_type: 'Product', sale_productable: product, quantity: 5, sale: sale)
        sale.cost_of_goods.should eq(50)
      end
    end

    context "tax_rate_total" do

      context "with products" do
        let(:store) { create(:store, tax_rate_inclusion: true) }
        before { store.tax_rates.first.update_attributes(amount: 8 ) }

        context "and with sale complete and !sale_product.price.nil?" do
          let(:sale) { create(:full_sale, store: store, status: 'complete') }
          let(:product){ create(:product, store: sale.store, tax_rate: store.tax_rates.first ) }
          let(:sale_product) { build(:sale_product, sale_productable_type: 'Product', sale_productable: product, price: 5, quantity: 4, sale: sale) }
          before { sale.sale_products << sale_product }

          context "with sale has discount" do
            context "discont value in currency" do
              before { create(:discount, value: 2, discountable: sale, discountable_type: 'Sale', kind: 'USD') }

              it "store inclusion" do
                sale.tax_rate_total.round(2).should eq(1.33)
              end

              it "store exclusion" do
                sale.store.update_attributes(tax_rate_inclusion: false)
                sale.tax_rate_total.should eq(1.44)
              end
            end

            context "discont value in percents" do
              before { create(:discount, value: 2, discountable: sale, discountable_type: 'Sale', kind: 'percent') }

              it "store inclusion" do
                sale.tax_rate_total.round(2).should eq(1.45)
              end

              it "store exclusion" do
                sale.store.update_attributes(tax_rate_inclusion: false)
                sale.tax_rate_total.should eq(1.568)
              end
            end

            context "discount value is 0" do
              before { create(:discount, value: 0, discountable: sale, discountable_type: 'Sale') }

              it "store inclusion" do
                sale.tax_rate_total.round(2).should eq(1.48)
              end

              it "store exclusion" do
                sale.store.update_attributes(tax_rate_inclusion: false)
                sale.tax_rate_total.should eq(1.6)
              end
            end

            context "discount value is 100 percents" do
              before { create(:discount, value: 100, discountable: sale, discountable_type: 'Sale', kind: 'percent') }

              it "store inclusion" do
                sale.tax_rate_total.round(2).should eq(0.0)
              end

              it "store exclusion" do
                sale.store.update_attributes(tax_rate_inclusion: false)
                sale.tax_rate_total.round(2).should eq(0.0)
              end
            end

            context "discount was destroyed" do
              before { create(:discount, discountable: sale, discountable_type: 'Sale') }

              it "store inclusion" do
                sale_product.discount.destroy
                sale.tax_rate_total.round(2).should eq(1.48)
              end

              it "store exclusion" do
                sale_product.discount.destroy
                sale.store.update_attributes(tax_rate_inclusion: false)
                sale.tax_rate_total.round(2).should eq(1.6)
              end
            end
          end

          context "without any discounts" do
            before { sale.sale_products << sale_product }

            it "store inclusion" do
              sale.tax_rate_total.round(2).should eq(1.48)
            end

            it "store exclusion" do
              sale.store.update_attributes(tax_rate_inclusion: false)
              sale.tax_rate_total.round(2).should eq(1.6)
            end
          end
        end

        context "and with sale_product.price nil" do
          let(:sale) { create(:full_sale, store: store, status: 'complete') }
          let(:product){ create(:product, store: sale.store, retail_price: 5, tax_rate: store.tax_rates.first ) }
          let(:sale_product) { build(:sale_product, price: nil, sale_productable_type: 'Product', sale_productable: product, quantity: 4, sale: sale) }
          before { sale.sale_products << sale_product }

          context "with sale_product has prod_discount" do
            context "discont value in currency" do
              before { create(:discount, value: 2, discountable: sale_product, discountable_type: 'SaleProduct', kind: 'USD') }

              it "store inclusion" do
                sale.tax_rate_total.round(2).should eq(1.33)
              end

              it "store exclusion" do
                sale.store.update_attributes(tax_rate_inclusion: false)
                sale.tax_rate_total.should eq(1.44)
              end
            end

            context "discont value in percents" do
              before { create(:discount, value: 2, discountable: sale_product, discountable_type: 'SaleProduct', kind: 'percent') }

              it "store inclusion" do
                sale.tax_rate_total.round(2).should eq(1.45)
              end

              it "store exclusion" do
                sale.store.update_attributes(tax_rate_inclusion: false)
                sale.tax_rate_total.should eq(1.568)
              end
            end

            context "discount value is 0" do
              before { create(:discount, value: 0, discountable: sale_product, discountable_type: 'SaleProduct') }

              it "store inclusion" do
                sale.tax_rate_total.round(2).should eq(1.48)
              end

              it "store exclusion" do
                sale.store.update_attributes(tax_rate_inclusion: false)
                sale.tax_rate_total.should eq(1.6)
              end
            end

            context "discount value is 100 percents" do
              before { create(:discount, value: 100, discountable: sale_product, discountable_type: 'SaleProduct', kind: 'percent') }

              it "store inclusion" do
                sale.tax_rate_total.round(2).should eq(0.0)
              end

              it "store exclusion" do
                sale.store.update_attributes(tax_rate_inclusion: false)
                sale.tax_rate_total.should eq(0.0)
              end
            end

            context "discount was destroyed" do
              before { create(:discount, discountable: sale_product, discountable_type: 'SaleProduct') }

              it "store inclusion" do
                sale_product.discount.destroy
                sale.tax_rate_total.round(2).should eq(1.48)
              end

              it "store exclusion" do
                sale_product.discount.destroy
                sale.store.update_attributes(tax_rate_inclusion: false)
                sale.tax_rate_total.should eq(1.6)
              end
            end
          end

          context "without any discounts" do
            before { sale.sale_products << sale_product }

            it "store inclusion" do
              sale.tax_rate_total.round(2).should eq(1.48)
            end

            it "store exclusion" do
              sale.store.update_attributes(tax_rate_inclusion: false)
              sale.tax_rate_total.should eq(1.6)
            end
          end
        end
      end

      context "with cards" do
        let(:sale) { create(:full_sale) }
        let(:gift_card_type) { create(:gift_card_type, value: 5) }
        let(:gift_card) { create(:gift_card, gift_card_type: gift_card_type) }
        let(:sale_product) { build(:sale_product, sale_productable_type: 'GiftCard', sale_productable: gift_card, quantity: 4, sale: sale) }

        it "store inclusion" do
          gift_card_type.save
          sale.sale_products << sale_product
          sale.tax_rate_total.should eq(0.0)
        end
      end

      # TODO: test event_customer_participants
      # TODO: test services_full_tax_rate_amount
    end

    context "services_grand_total" do
      let(:sale){ build(:full_sale) }
      let(:product){ create(:product, store: sale.store, tax_rate: create(:tax_rate, store: sale.store)) }
      let(:sale_product_product) { build(:sale_product, sale_productable_type: 'Product', sale_productable: product) }

      let(:service_1){ create(:service, status: 'booked', sale: sale, store: sale.store, customer: Customer.first, user: User.first, type_of_service: type_of_service_1) }
      let(:service_2){ create(:service, status: 'booked', sale: sale, store: sale.store, customer: Customer.first, user: User.first, type_of_service: type_of_service_2) }
      let(:sale_product_1){ build(:sale_product, sale_productable_type: 'Service', sale_productable: service_1) }
      let(:sale_product_2){ build(:sale_product, sale_productable_type: 'Service', sale_productable: service_2) }

      context "without service_kit and without products" do
        let(:type_of_service_1) { create(:type_of_service, store: sale.store, labour: 2, labour_price: 5) }
        let(:type_of_service_2) { create(:type_of_service, store: sale.store, labour:3, labour_price: 10) }

        it "calculates services" do
          sale.sale_products << sale_product_1
          sale.sale_products << sale_product_2
          sale.services_grand_total.should eq(40.0)
        end

        it "calculates only services" do
          sale.sale_products << sale_product_1
          sale.sale_products << sale_product_product
          sale.services_grand_total.should eq(10.0)
        end
      end

      context "with service_kit" do
        context "calculates services with type_of_service.price_of_service_kit 'included'" do
          let(:type_of_service_1) { create(:type_of_service, store: sale.store, labour: 2, labour_price: 5, price_of_service_kit: 'included') }
          let(:type_of_service_2) { create(:type_of_service, store: sale.store, labour:3, labour_price: 10, price_of_service_kit: 'included') }
          before do
            create(:service_kit, type_of_service: type_of_service_1)
            create(:service_kit, type_of_service: type_of_service_2)
            sale.sale_products << sale_product_1
            sale.sale_products << sale_product_2
          end

          it "without products" do
            sale.services_grand_total.should eq(40.0)
          end

          #TODO: check service.grand_total if service has products
          xit "with products" do
            service_item_1 = create(:service_item, product: product, service: service_1)
            sale.services_grand_total.should eq(40.0)
          end
        end

        context "calculates services with type_of_service.price_of_service_kit not equal 'included'" do
          let(:type_of_service_1) { create(:type_of_service, store: sale.store, labour: 2, labour_price: 5, price_of_service_kit: 'additional') }
          let(:type_of_service_2) { create(:type_of_service, store: sale.store, labour:3, labour_price: 10, price_of_service_kit: 'additional') }
          before do
            create(:service_kit, type_of_service: type_of_service_1, retail_price: 400)
            create(:service_kit, type_of_service: type_of_service_2, retail_price: 350)
            sale.sale_products << sale_product_1
            sale.sale_products << sale_product_2
          end

          it "without products" do
            sale.services_grand_total.should eq(790.0)
          end

          #TODO: check service.grand_total if service has products
          xit "with products" do
            service_item_1 = create(:service_item, product: product, service: service_1)
            sale.services_grand_total.should eq(790.0)
          end
        end
      end
    end

    context "calc_grand_total" do
      context "with products" do
        let(:sale) { create(:full_sale, status: 'active') }
        let(:product){ create(:product, store: sale.store, retail_price: 5 ) }
        let(:sale_product) { build(:sale_product, sale_productable_type: 'Product', sale_productable: product, quantity: 4, sale: sale) }
        before { sale.sale_products << sale_product }

        context "with discont value in percents" do
          before { create(:discount, value: 2, discountable: sale_product, discountable_type: 'SaleProduct', kind: 'percent') }
          it "with sale not refund" do
            sale.calc_grand_total.should eq(19.6)
          end

          it "with sale refund" do
            sale.update_attributes(status: 'refund')
            sale.calc_grand_total.should eq(-19.6)
          end
        end

        context "discont value in currency" do
          before { create(:discount, value: 2, discountable: sale_product, discountable_type: 'SaleProduct', kind: 'USD') }
          it "with sale not refund" do
            sale.calc_grand_total.should eq(18.0)
          end

          it "with sale refund" do
            sale.update_attributes(status: 'refund')
            sale.calc_grand_total.should eq(-18.0)
          end
        end

        context "discount value is 0" do
          before { create(:discount, value: 0, discountable: sale_product, discountable_type: 'SaleProduct') }
          it "with sale not refund" do
            sale.calc_grand_total.should eq(20.0)
          end

          it "with sale refund" do
            sale.update_attributes(status: 'refund')
            sale.calc_grand_total.should eq(-20.0)
          end
        end

        context "discount value is 100 percents" do
          before { create(:discount, value: 100, discountable: sale_product, discountable_type: 'SaleProduct', kind: 'percent') }
          it "with sale not refund" do
            sale.calc_grand_total.should eq(0.0)
          end

          it "with sale refund" do
            sale.update_attributes(status: 'refund')
            sale.calc_grand_total.should eq(0.0)
          end
        end

        context "discount was destroyed" do
          before { create(:discount, discountable: sale_product, discountable_type: 'SaleProduct') }
          it "with sale not refund" do
            sale_product.discount.destroy
            sale.calc_grand_total.should eq(20.0)
          end

          it "with sale refund" do
            sale_product.discount.destroy
            sale.update_attributes(status: 'refund')
            sale.calc_grand_total.should eq(-20.0)
          end
        end

        context "without any discounts" do
          it "with sale not refund" do
            sale.calc_grand_total.should eq(20.0)
          end

          it "with sale refund" do
            sale.update_attributes(status: 'refund')
            sale.calc_grand_total.should eq(-20.0)
          end
        end
      end

      # TODO: test event_customer_participants
      # TODO: test services_grand_total
    end

    context "payment_tendered" do
      let(:sale) { create(:full_sale) }
      let(:payment_method) { PaymentMethod.find_by_name('Cash') }
      before do
        create(:payment, sale: sale, payment_method: payment_method, amount: 5)
        create(:payment, sale: sale, payment_method: payment_method, amount: 10)
      end

      it { sale.payment_tendered.should eq({PaymentMethod.first.name=>15.0}) }
    end

    context "change_amount" do
      let(:sale) { create(:full_sale) }
      let(:payment_method) { PaymentMethod.find_by_name('Cash') }
      before do
        create(:payment, sale: sale, payment_method: payment_method, amount: 5)
        create(:payment, sale: sale, payment_method: payment_method, amount: 10)
        sale.update_attributes(grand_total: 5)
      end

      it { sale.change_amount.should eq(10.0) }
    end

    context "empty!" do
      let(:sale) { create(:full_sale, status: 'layby') }
      before do
        create(:payment, sale: sale)
        product = create(:product, store: sale.store, tax_rate: create(:tax_rate, store: sale.store))
        create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale)
      end

      it { expect{sale.empty!}.to change{Payment.count}.by(-1) }
      it { expect{sale.empty!}.to change{SaleProduct.count}.by(-1) }
      it { expect{sale.empty!}.to change{sale.status}.to('active') }
    end

    context "can_contain_discount?" do
      let(:sale) { create(:full_sale) }
      let(:product){ create(:product, store: sale.store ) }
      let(:sale_product) { build(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale) }
      before { sale.sale_products << sale_product }

      context "without prod_discount" do
        it { sale.can_contain_discount?.should be(true) }
      end

      context "with prod_discount" do
        before { create(:discount, discountable: sale_product, discountable_type: 'SaleProduct') }
        it { sale.can_contain_discount?.should be(false) }
      end
    end

    context "paid?" do
      context "with refund status" do
        it "with positive change" do
          sale = build(:full_sale, status: 'refund', change: 5)
          sale.paid?.should be_false
        end

        it "with negative change" do
          sale = build(:full_sale, status: 'refund', change: -5)
          sale.paid?.should be_true
        end
      end

      context "with status not refund" do
        it "with positive change" do
          sale = build(:full_sale, status: 'active', change: 5)
          sale.paid?.should be_true
        end

        it "with negative change" do
          sale = build(:full_sale, status: 'active', change: -5)
          sale.paid?.should be_false
        end
      end
    end

    context "can_be_completed?" do
      context "with status layby" do
        context "when paid" do
          let(:sale) { create(:full_sale, status: 'layby') }
          before { sale.update_attributes(change: 5) }
          context "with sale_product" do
            let(:product){ create(:product, store: sale.store ) }
            let(:sale_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale) }
            before { sale.sale_products << sale_product }

            it { sale.can_be_completed?.should be_true }
          end

          context "with event_customer_participants" do
            let(:event_customer_participant) { create(:event_customer_participant, sale: sale) }
            before { sale.event_customer_participants << event_customer_participant }
            it { sale.can_be_completed?.should be_true }
          end

          context "without sale_products and event_customer_participants" do
            it { sale.can_be_completed?.should be_false }
          end
        end

        context "when not paid" do
          let(:sale) { create(:full_sale, status: 'layby') }
          before { sale.update_attributes(change: -5) }
          it { sale.can_be_completed?.should be_false }
        end
      end

      context "with status refund" do
        context "when paid" do
          let(:sale) { create(:full_sale, status: 'refund') }
          before { sale.update_attributes(change: -5) }
          context "with sale_product" do
            let(:product){ create(:product, store: sale.store ) }
            let(:sale_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale) }
            before { sale.sale_products << sale_product }

            it { sale.can_be_completed?.should be_true }
          end

          context "with event_customer_participants" do
            let(:event_customer_participant) { create(:event_customer_participant, sale: sale) }
            before { sale.event_customer_participants << event_customer_participant }
            it { sale.can_be_completed?.should be_true }
          end

          context "without sale_products and event_customer_participants" do
            it { sale.can_be_completed?.should be_false }
          end
        end

        context "when not paid" do
          let(:sale) { create(:full_sale, status: 'layby') }
          before { sale.update_attributes(change: 5) }
          it { sale.can_be_completed?.should be_false }
        end
      end

      context "with grand_total zero" do
        context "when paid" do
          let(:sale) { create(:full_sale, status: 'active', grand_total: 0) }
          before { sale.update_attributes(change: 5) }
          context "with sale_product" do
            let(:product){ create(:product, store: sale.store ) }
            let(:sale_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale) }
            before { sale.sale_products << sale_product }

            it { sale.can_be_completed?.should be_true }
          end

          context "with event_customer_participants" do
            let(:event_customer_participant) { create(:event_customer_participant, sale: sale) }
            before { sale.event_customer_participants << event_customer_participant }
            it { sale.can_be_completed?.should be_true }
          end

          context "without sale_products and event_customer_participants" do
            it { sale.can_be_completed?.should be_false }
          end
        end

        context "when not paid" do
          let(:sale) { create(:full_sale, status: 'layby', grand_total: 0) }
          before { sale.update_attributes(change: -5) }
          it { sale.can_be_completed?.should be_false }
        end
      end
    end

    context "can_be_outstanding?" do
      context "when not paid" do
        let(:sale) { create(:full_sale, status: 'layby') }
        before { sale.update_attributes(change: -5) }

        context "with sale_product" do
          let(:product){ create(:product, store: sale.store ) }
          let(:sale_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale) }
          before { sale.sale_products << sale_product }
          it { sale.can_be_outstanding?.should be_true }
        end

        context "with event_customer_participants" do
          let(:event_customer_participant) { create(:event_customer_participant, sale: sale) }
          before { sale.event_customer_participants << event_customer_participant }
          it { sale.can_be_outstanding?.should be_true }
        end
      end

      context "when paid" do
        let(:sale) { create(:full_sale, status: 'layby') }
        before { sale.update_attributes(change: 5) }
        it { sale.can_be_outstanding?.should be_false }
      end
    end

    context "outstanding?" do
      context "with status active" do
        let(:sale) { create(:full_sale, status: 'active') }
        it { sale.outstanding?.should be_true }
      end

      context "with status layby" do
        let(:sale) { create(:full_sale, status: 'layby') }
        it { sale.outstanding?.should be_true }
      end

      context "with status refund" do
        let(:sale) { create(:full_sale, status: 'refund') }
        it { sale.outstanding?.should be_true }
      end

      context "with status complete" do
        let(:sale) { create(:full_sale, status: 'complete') }
        it { sale.outstanding?.should be_false }
      end
    end

    context "refunded?" do
      context "with status refund" do
        let(:sale) { create(:full_sale, status: 'refund') }
        it { sale.refunded?.should be_true }
      end

      context "with status complete_refund" do
        let(:sale) { create(:full_sale, status: 'complete_refund') }
        it { sale.refunded?.should be_true }
      end

      context "with status active" do
        let(:sale) { create(:full_sale, status: 'active') }
        it { sale.refunded?.should be_false }
      end
    end

    context "completed?" do
      context "with status complete" do
        let(:sale) { create(:full_sale, status: 'complete') }
        it { sale.completed?.should be_true }
      end

      context "with status complete_layby" do
        let(:sale) { create(:full_sale, status: 'complete_layby') }
        it { sale.completed?.should be_true }
      end

      context "with status active" do
        let(:sale) { create(:full_sale, status: 'active') }
        it { sale.completed?.should be_false }
      end
    end

    context "refund_quantity_limit" do
      context "with status refund" do
        let(:sale) { create(:full_sale, status: 'refund') }
        let(:product){ create(:product, store: sale.store ) }
        let(:sale_product_parent) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale, quantity: 7) }
        let(:sale_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale, original_id: sale_product_parent, quantity: 3) }
        before { sale.sale_products << sale_product }
        it { sale.refund_quantity_limit.should eq(10) }
      end

      context "with status not refund" do
        let(:sale) { create(:full_sale, status: 'active') }
        let(:product){ create(:product, store: sale.store ) }
        let(:sale_product_parent) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale, quantity: 7) }
        let(:sale_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale, original_id: sale_product_parent, quantity: 3) }
        before { sale.sale_products << sale_product }
        xit { sale.refund_quantity_limit.should eq(10) }
      end
    end

    context "can_be_refunded?" do
      context "with not refunded" do
        let(:sale) { create(:full_sale, status: 'active') }

        context "with refund_quantity_limit" do
          let(:product){ create(:product, store: sale.store ) }
          let(:sale_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale, quantity: 7) }
          before { sale.sale_products << sale_product }

          it { sale.can_be_refunded?.should be_true }
        end

        context "with event_customer_participants" do
          let(:event_customer_participant) { create(:event_customer_participant, sale: sale) }
          before { sale.event_customer_participants << event_customer_participant }

          it { sale.can_be_refunded?.should be_true }
        end

        context "without refund_quantity_limit and event_customer_participants" do
          it { sale.can_be_refunded?.should be_false }
        end
      end

      context "with refunded" do
        let(:sale) { create(:full_sale, status: 'complete_refund') }

        context "with refund_quantity_limit" do
          let(:product){ create(:product, store: sale.store ) }
          let(:sale_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale, quantity: 7) }
          before { sale.sale_products << sale_product }

          it { sale.can_be_refunded?.should be_false }
        end

        context "with event_customer_participants" do
          let(:event_customer_participant) { create(:event_customer_participant, sale: sale) }
          before { sale.event_customer_participants << event_customer_participant }

          it { sale.can_be_refunded?.should be_false }
        end

        context "without refund_quantity_limit and event_customer_participants" do
          it { sale.can_be_refunded?.should be_false }
        end
      end
    end

    context "receipt_id" do
      let(:sale) { create(:full_sale) }
      it { sale.receipt_id.should eq(sale.id) }
    end

    context "to_pay" do
      context "with complete? true" do
        let(:sale) { create(:full_sale, status: 'complete') }
        it { sale.to_pay.should eq(0) }
      end

      context "with complete? false" do
        context "with positive change" do
          let(:sale) { build(:full_sale, grand_total: 500, status: 'active', change: 5.3) }
          it { expect(sale.to_pay.to_f).to eq 500 }
        end

        context "with negative change" do
          let(:sale) { build(:full_sale, grand_total: 500, status: 'active', change: -5.3) }
          it { sale.to_pay.to_f.should eq(500) }
        end
      end
    end

    # FIXME:
    context "add_events!" do
      context "with ecp_id" do
        let(:sale) { create(:full_sale) }
        let(:ecp) { create(:event_customer_participant, sale_id: nil) }
        let(:customer) { create(:customer) }
        xit "" do
          #sale.add_events!(ecp_id: ecp.id)
          expect { sale.add_events!(ecp_id: ecp.id) }.to change{ ecp.sale_id }.from(nil).to(sale.id)
          #sale.add_events!(ecp_id: ecp.id, customer_id: customer.id)
        end
      end
    end

    context "create_empty" do
      let(:store) { create(:store) }
      let(:creator) { create(:user, company: store.company) }
      let(:customer) { create(:customer, company: store.company) }

      context "with customer" do
        it { expect { Sale.create_empty(creator, store, customer.id) }.to change{Sale.count}.by(1) }
        it { expect { Sale.create_empty(creator, store, customer.id) }.to change{SaleCustomer.count}.by(1) }

        it "with company customer" do
          Sale.create_empty(creator, store, customer.id)
          Sale.first.sale_customers.first.customer_id.should eq(customer.id)
        end
      end

      context "with customer = nil" do
        it { expect { Sale.create_empty(creator, store, store.company.customers.first.id) }.to change{Sale.count}.by(1) }
        it { expect { Sale.create_empty(creator, store, store.company.customers.first.id) }.to change{SaleCustomer.count}.by(1) }
        it "with default company customer" do
          Sale.create_empty(creator, store)
          Sale.first.sale_customers.first.customer_id.should eq(store.company.customers.first.id)
        end
      end
    end

    #TODO: test for refund! method

    #TODO test for refund_event method
    context "refund_event" do
      #let(:sale) { create(:sale_with_event_customer_participant, status: 'refund') }
      let(:sale) { create(:full_sale) }
      let(:event_customer_participant) { create(:event_customer_participant, sale: sale) }
      xit "" do
        sale.refund_event(event_customer_participant)
      end
    end

    context "update_gift_cards_status" do
      let(:sale) { create(:full_sale) }
      let(:gift_card_type) { build(:gift_card_type, value: 5) }
      let(:gift_card) { create(:gift_card, status: "not_sold", solded_at: Time.now-1.day, gift_card_type: gift_card_type ) }
      let(:sale_product) { build(:sale_product, sale_productable_type:"GiftCard", sale_productable: gift_card, sale: sale) }
      before { sale.sale_products << sale_product }
      it { expect { sale.update_gift_cards_status }.to change{ sale.sale_products.first.sale_productable.status }.from("not_sold").to("un-used") }
      it { expect { sale.update_gift_cards_status }.to change{ sale.sale_products.first.sale_productable.solded_at.to_i }.to(Time.now.utc.to_i) }
    end

    context "find_gift_cards" do
      let(:sale) { create(:full_sale) }
      let(:gift_card_type) { build(:gift_card_type) }
      let(:gift_card) { create(:gift_card, gift_card_type: gift_card_type ) }
      let(:sale_product_gift_card) { build(:sale_product, sale_productable_type:"GiftCard", sale_productable: gift_card, sale: sale) }


      let(:product){ create(:product, store: sale.store ) }
      let(:sale_product_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale) }

      before do
        sale.sale_products << sale_product_gift_card
        sale.sale_products << sale_product_product
      end

      it { sale.find_gift_cards.should eq([gift_card]) }
    end

    context "has_only_walkin?" do
      let(:sale) { create(:full_sale) }
      let(:walk_in) { create(:customer, given_name: 'Walk', family_name: 'In') }
      let(:sale_customer) { create(:sale_customer, sale: sale, customer: walk_in) }

      before{ sale.sale_customers << sale_customer }
      it{ sale.has_only_walkin?.should be_true }
    end

    context "name" do
      context "with refunded status" do
        let(:sale) { create(:full_sale, status: 'refund') }
        it { sale.name.should eq("##{sale.id} [REFUNDED]") }
      end

      context "with not refunded status" do
        let(:sale) { create(:full_sale) }
        it { sale.name.should eq("##{sale.id} ") }
      end
    end

    #TODO: apply_tariff_discount
    #TODO: apply_default_discount
    #TODO: apply_default_discount_for_products
    #TODO: sale_discount
    #TODO: line_items_has_discount

    context "has_discount" do
      let(:sale) { create(:full_sale) }

      context "with discount" do
        before { create(:discount, value: 2, discountable: sale, discountable_type: 'Sale') }
        it{ sale.has_discount.should be_true }
      end

      context "without discount" do
        it{ sale.has_discount.should be_false }
      end
    end

    context "freeze_product_prices" do
      context "with complete status" do
        let(:sale) { create(:full_sale, status: 'complete') }
        let(:product){ create(:product, store: sale.store, retail_price: 20 ) }
        before{ sale.sale_products << sale_product}

        context "with sale_product price" do
          let(:sale_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale, price: 10) }
          it{ expect{ sale.freeze_product_prices}.not_to change{ sale.sale_products.first.price }}
        end

        context "without sale_product price" do
          let(:sale_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale, price: nil) }
          it{ expect{ sale.freeze_product_prices}.to change{ sale.sale_products.first.price }.to(20)}
        end
      end

      context "with status not equal complete" do
        let(:sale) { create(:full_sale) }
        let(:product){ create(:product, store: sale.store, retail_price: 20 ) }
        let(:sale_product) { create(:sale_product, sale_productable_type: 'Product', sale_productable: product, sale: sale, price: 10) }
        before{ sale.sale_products << sale_product}

        it{ expect{ sale.freeze_product_prices}.to change{ sale.sale_products.first.price }.to(20) }
      end
    end

    #TODO: calc_taxable_revenue

    context "attrs_for_clone" do
      let(:sale) { create(:full_sale) }
      it{ sale.send(:attrs_for_clone).should eq({status: 'refund', store_id: sale.store_id, creator_id: sale.creator_id}) }
    end

    context "update_status_for_service" do
      context "with not complete status" do
        let(:sale) { create(:full_sale, status: 'active') }
        it { sale.send(:update_status_for_service).should be_nil }
      end

      context "with complete status" do
        let(:sale) { create(:full_sale, status: 'complete') }
        let(:type_of_service) { create(:type_of_service, store: sale.store) }
        let(:service){ create(:service, status: 'booked', sale: sale, store: sale.store, customer: Customer.first, user: User.first, type_of_service: type_of_service) }
        let(:sale_product){ build(:sale_product, sale_productable_type: 'Service', sale_productable: service) }

        before { sale.sale_products << sale_product }
        it do
          sale.send(:update_status_for_service)
          sale.sale_products.first.sale_productable.status.should eq('complete')
        end
      end
    end
  end
end
