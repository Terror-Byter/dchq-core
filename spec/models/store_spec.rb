require 'spec_helper'

describe Store do
  let(:store){ create(:store) }

  context '#DB' do
    it { expect(subject).to have_db_index(:company_id) }
    it { expect(subject).to have_db_index(:currency_id) }
  end

  context '#Associations' do
    it { expect(subject).to have_and_belong_to_many(:users) }
    it { expect(subject).to have_many(:certification_levels) }
    it { expect(subject).to have_many(:certification_level_costs) }
    it { expect(subject).to have_many(:payment_methods) }
    it { expect(subject).to have_many(:tax_rates) }
    it { expect(subject).to have_many(:commission_rates) }
    it { expect(subject).to have_many(:event_trips) }
    it { expect(subject).to have_many(:events) }
    it { expect(subject).to have_many(:course_events) }
    it { expect(subject).to have_many(:other_events) }
    it { expect(subject).to have_many(:event_customer_participants).through(:sales) }
    it { expect(subject).to have_many(:customer_participants).through(:events) }
    it { expect(subject).to have_many(:boats).class_name("Stores::Boat") }
    it { expect(subject).to have_many(:events_with_boats).through(:boats).source(:events).order(:starts_at) }
    it { expect(subject).to have_many(:working_times).class_name("Stores::WorkingTime") }
    it { expect(subject).to have_many(:event_tariffs).class_name("Stores::EventTariff") }
    it { expect(subject).to have_many(:finance_reports).class_name("Stores::FinanceReport") }
    it { expect(subject).to have_many(:invoices).class_name("Stores::Invoice") }
    it { expect(subject).to have_many(:credits).class_name("Stores::Credit") }
    it { expect(subject).to have_one(:email_setting).class_name("Stores::EmailSetting") }
    it { expect(subject).to have_many(:kit_hires).class_name("ExtraEvents::KitHire") }
    it { expect(subject).to have_many(:transports).class_name("ExtraEvents::Transport") }
    it { expect(subject).to have_many(:insurances).class_name("ExtraEvents::Insurance") }
    it { expect(subject).to have_many(:additionals).class_name("ExtraEvents::Additional") }
    it { expect(subject).to have_many(:type_of_services).class_name("Services::TypeOfService") }
    it { expect(subject).to have_many(:service_kits).class_name("Services::ServiceKit") }
    it { expect(subject).to have_many(:services) }
    it { expect(subject).to have_many(:categories) }
    it { expect(subject).to have_many(:brands) }
    it { expect(subject).to have_many(:products) }
    it { expect(subject).to have_many(:miscellaneous_products) }
    it { expect(subject).to have_many(:sales) }
    it { expect(subject).to have_many(:sale_customers).through(:sales) }
    it { expect(subject).to have_many(:sale_products).through(:sales) }
    it { expect(subject).to have_many(:credit_notes).through(:sales) }
    it { expect(subject).to have_many(:tills).dependent(:destroy) }
    it { expect(subject).to have_many(:sold_products).through(:sales).source(:products) }
    it { expect(subject).to have_many(:payments).through(:sales) }
    it { expect(subject).to have_many(:rental_products) }
    it { expect(subject).to have_many(:rentals) }
    it { expect(subject).to have_one(:xero).class_name("Stores::Xero") }
    it { expect(subject).to have_one(:avatar).class_name("Image").dependent(:destroy) }
  end

  context 'Accepts Nested Attributes' do
    it { expect(subject).to accept_nested_attributes_for(:avatar).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:email_setting) }
    it { expect(subject).to accept_nested_attributes_for(:type_of_services).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:boats).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:service_kits).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:payment_methods).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:event_tariffs).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:xero).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:finance_reports).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:tills).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:tax_rates).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:commission_rates).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:certification_levels).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:event_trips).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:kit_hires).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:transports).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:insurances).allow_destroy(true) }
    it { expect(subject).to accept_nested_attributes_for(:additionals).allow_destroy(true) }
  end

  context 'Validations' do
    it { expect(subject).to validate_presence_of(:company) }
    it { expect(subject).to ensure_length_of(:standart_rental_term).is_at_most(65536) }
    it { expect(subject).to validate_presence_of(:name) }
    it { expect(subject).to ensure_length_of(:name).is_at_most(255) }
    it { expect(subject).to validate_presence_of(:location) }
    it { expect(subject).to validate_presence_of(:time_zone) }
    it { expect(subject).to ensure_inclusion_of(:time_zone).in_array(ActiveSupport::TimeZone.all.map(&:name)) }
    it { expect(subject).to validate_presence_of(:currency) }
    it { expect(subject).to validate_presence_of(:printer_type) }
    it { expect(subject).to ensure_inclusion_of(:printer_type).in_array(Store.printer_types.keys) }
    it { expect(subject).to validate_presence_of(:calendar_type) }
    it { expect(subject).to ensure_inclusion_of(:calendar_type).in_array(Store.calendar_types.keys) }
    it { expect(subject).to validate_presence_of(:printer_type) }
    it { expect(subject).to ensure_inclusion_of(:printer_type).in_array(Store.printer_types.keys) }
    context 'tsp_url should be presence' do
    before { subject.stub(:printer_type) { 'tsp' } }
      it { expect(subject).to validate_presence_of(:tsp_url) }
    end

    context 'tsp_url should_not be presence' do
    before { subject.stub(:printer_type) { false } }
      it { expect(subject).to_not validate_presence_of(:tsp_url) }
    end
  end

  context 'Allow Mass Assigned Attributes' do
    it { expect(subject).to allow_mass_assignment_of(:standart_rental_term) }
    it { expect(subject).to allow_mass_assignment_of(:company_id) }
    it { expect(subject).to allow_mass_assignment_of(:finance_reports_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:tills_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:name) }
    it { expect(subject).to allow_mass_assignment_of(:location) }
    it { expect(subject).to allow_mass_assignment_of(:currency) }
    it { expect(subject).to allow_mass_assignment_of(:currency_id) }
    it { expect(subject).to allow_mass_assignment_of(:printer_type) }
    it { expect(subject).to allow_mass_assignment_of(:time_zone) }
    it { expect(subject).to allow_mass_assignment_of(:main) }
    it { expect(subject).to allow_mass_assignment_of(:invoice_id) }
    it { expect(subject).to allow_mass_assignment_of(:calendar_type) }
    it { expect(subject).to allow_mass_assignment_of(:standart_term) }
    it { expect(subject).to allow_mass_assignment_of(:barcode_printing_type) }
    it { expect(subject).to allow_mass_assignment_of(:tax_rate_inclusion) }
    it { expect(subject).to allow_mass_assignment_of(:email_setting_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:type_of_services_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:boats_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:service_kits_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:payment_methods_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:event_tariffs_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:avatar_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:xero_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:tax_rates_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:commission_rates_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:certification_levels_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:event_trips_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:transports_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:insurances_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:kit_hires_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:additionals_attributes) }
    it { expect(subject).to allow_mass_assignment_of(:tsp_url) }
  end

  describe 'Default Values' do
    context '#printer_type' do
      it 'should has value 80mm' do
        expect(store.printer_type).to eq '80mm'
      end
    end

    context '#time_zone' do
      it 'should has value "London"' do
        expect(store.time_zone).to eq 'London'
      end
    end

    context '#main' do
      it 'should be true' do
        expect(store.main).to be_truthy
      end

      it 'should has method maim?' do
        expect(store.main?).to be_truthy
      end
    end

    context '#calendar_type' do
      it 'should has value month' do
        expect(store.calendar_type).to eq 'month'
      end
    end

    context '#barcode_printing_type' do
      it 'should be a4' do
        expect(store.barcode_printing_type).to eq 'a4'
      end
    end

    context '#tax_rate_inclusion' do
      it 'should be true' do
        expect(store.tax_rate_inclusion).to be_truthy
      end

      it 'should has method tax_rate_inclusion?' do
        expect(store.tax_rate_inclusion?).to be_truthy
      end
    end

    context '#Api key' do
      it 'should not be empty' do
        expect(store.api_key.blank?).to be_falsey
      end
    end

    context 'Public key' do
      it 'should not be empty' do
        expect(store.public_key.blank?).to be_falsey
      end
    end

    it 'should has default email settings' do
      expect(store.email_setting.blank?).to be_falsey
    end

    context 'default payment_methods' do
      it 'should has default payment_methods' do
        expect(store.payment_methods.blank?).to be_falsey
      end

      it 'should has "Cash" default payment method' do
        expect(store.payment_methods.pluck(:name).sort).to eq(["Cash", "Credit Card", "Paypal"])
      end
    end

    context 'default tax_rates' do
      it 'should has default tax rates' do
        expect(store.tax_rates.blank?).to be_falsey
      end

      it 'should has "0.0" default tax rate' do
        expect(store.tax_rates.pluck(:amount)).to eq([0.0])
      end
    end

    context 'default commission_rates' do
      it 'should has default commission rates' do
        expect(store.commission_rates.blank?).to be_falsey
      end

      it 'should has "0.0" default commission rate' do
        expect(store.commission_rates.pluck(:amount)).to eq([0.0])
      end
    end

    context 'add_working_time' do
      it 'should has open_time' do
        expect(store.working_times.blank?).to be_falsey
      end
    end

    context 'add_managers_to_store' do
      it 'should add managers' do
        expect(store.users.empty?).to be_falsey
      end

      it 'added user should be manager' do
        expect(store.users.first.manager?).to be_truthy
      end
    end
  end

  describe 'Methods' do
    context '#tax_rates_list' do
      it 'should return list of tax rates' do
        expect(store.tax_rates_list).to eq(store.tax_rates.map{ |tr| [tr.amount, tr.id] })
      end
    end

    context '#commission_rates_list' do
      it 'should return list of commission rates' do
        expect(store.commission_rates_list).to eq(store.commission_rates.map{ |cr| [cr.amount, cr.id] })
      end
    end
  end
end
