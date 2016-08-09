require 'spec_helper'

describe RentalsController do
  let(:user){ create(:user) }
  let(:company){ user.company }
  let(:store){ company.stores.first }
  let(:rental){ create(:rental, store: store, user: user, customer: company.customers.first) }
  let(:category){ create(:category, store: store) }
  let(:brand){ create(:brand, store: store) }
  let(:supplier){ create(:supplier, company: company) }
  let(:rental_product){ create(:rental_product, store: store, category: category, brand: brand, supplier: supplier) }
  let(:rented){ create(:rented, rental: rental, rental_product: rental_product) }
  let(:rental_payment){ create(:rental_payment, rental: rental, amount: 50, payment_method: store.payment_methods.first, cashier: user) }

  context '#send_receipt_via_email' do
    before do
      sign_in user

      rental
      rented
      rental_payment

      post :send_receipt_via_email, id: rental.id, email: 'vitaliy@oceanshq.com'
    end

    it { should redirect_to rental }
    it { should set_the_flash[:notice].to(I18n.t("controllers.receipt_send")) }
    #it { expect(ActionMailer::Base.deliveries.count).to_not be_zero }
  end
end
