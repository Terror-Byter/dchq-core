require 'spec_helper'

describe Event do
  context 'DB' do
    it { expect(subject).to have_db_index(:store_id) }
    it { expect(subject).to have_db_index(:boat_id) }
    it { expect(subject).to have_db_index(:event_type_id) }
  end

  context 'Associations' do
    it { expect(subject).to belong_to(:store) }
    it { expect(subject).to belong_to(:boat).class_name('Stores::Boat') }
    it { expect(subject).to belong_to(:event_type) }
    it { expect(subject).to have_many(:event_customer_participant_transports).through(:event_customer_participants) }
    it { expect(subject).to have_many(:customer_participants).class_name('EventCustomerParticipant') }
    it { expect(subject).to have_many(:sales).through(:event_customer_participants) }
    it { expect(subject).to have_many(:customers).through(:event_customer_participants) }
    it { expect(subject).to have_many(:event_user_participants).dependent(:destroy) }
    it { expect(subject).to have_many(:event_customer_participants).dependent(:destroy) }
  end

  context 'Mass Assign Protection' do
    it { expect(subject).to allow_mass_assignment_of(:name) }
    it { expect(subject).to allow_mass_assignment_of(:event_type_id) }
    it { expect(subject).to allow_mass_assignment_of(:certification_level_id) }
    it { expect(subject).to allow_mass_assignment_of(:event_trip_id) }
    it { expect(subject).to allow_mass_assignment_of(:starts_at) }
    it { expect(subject).to allow_mass_assignment_of(:ends_at) }
    it { expect(subject).to allow_mass_assignment_of(:additional_equipment) }
    it { expect(subject).to allow_mass_assignment_of(:price) }
    it { expect(subject).to allow_mass_assignment_of(:private) }
    it { expect(subject).to allow_mass_assignment_of(:store_id) }
    it { expect(subject).to allow_mass_assignment_of(:frequency) }
    it { expect(subject).to allow_mass_assignment_of(:created_at) }
    it { expect(subject).to allow_mass_assignment_of(:updated_at) }
    it { expect(subject).to allow_mass_assignment_of(:parent_id) }
    it { expect(subject).to allow_mass_assignment_of(:notes) }
    it { expect(subject).to allow_mass_assignment_of(:enable_booking) }
    it { expect(subject).to allow_mass_assignment_of(:limit_of_registrations) }
    it { expect(subject).to allow_mass_assignment_of(:location) }
    it { expect(subject).to allow_mass_assignment_of(:instructions) }
    it { expect(subject).to allow_mass_assignment_of(:cancel) }
    it { expect(subject).to allow_mass_assignment_of(:boat_id) }
    it { expect(subject).to allow_mass_assignment_of(:number_of_frequencies) }
    it { expect(subject).to allow_mass_assignment_of(:number_of_dives) }
    it { expect(subject).to allow_mass_assignment_of(:type) }
  end

  context 'Nested Attributes' do
    it { accept_nested_attributes_for(:event_customer_participants) }
    it { accept_nested_attributes_for(:event_user_participants) }
  end

  context 'Validations' do
    it { expect(subject).to validate_presence_of(:store) }
    it { expect(subject).to validate_presence_of(:starts_at) }
    it { expect(subject).to_not allow_value('', nil, 123, 'asda').for(:starts_at) }
    it { expect(subject).to validate_presence_of(:ends_at) }
    it { expect(subject).to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { expect(subject).to allow_value(0, nil).for(:price) }
    it { expect(subject).to ensure_length_of(:additional_equipment).is_at_most(255) }
    it { expect(subject).to allow_value(nil, '').for(:additional_equipment) }
    it { expect(subject).to allow_value(nil, 0, '', 12, 0.2).for(:limit_of_registrations) }
    it { expect(subject).to_not allow_value('sadsad', -23, true, false).for(:limit_of_registrations) }
    it { expect(subject).to allow_value(true, false).for(:cancel) }
    it { expect(subject).to validate_numericality_of(:number_of_dives).is_greater_than_or_equal_to(0) }
    it { expect(subject).to validate_presence_of(:event_type) }
  end

  context 'CourseEvent' do
    let(:store){ create(:store) }
    let(:course_event){ create(:course_event, store: store) }

    context '#Methods' do
      #context '#distance_in_days' do
        #it 'should return 1' do
          #expect(course_event.distance_in_days).to eq 1
        #end

        #it 'should return 3' do
          #another_course = create(:course_event, store: store, starts_at: Time.now, ends_at: Time.now + 3.days)
          #expect(another_course.distance_in_days).to eq 3
        #end
      #end

      #context '#available?' do
        #it 'should return true' do
          #expect(course_event.available?).to be_truthy
        #end

        #it 'should return false' do
          #course_event = create(:course_event, store: store, starts_at: Time.now - 20.days, ends_at: Time.now - 19.days)
          #expect(course_event.available?).to be_falsey
        #end
      #end

      #context '#available_places' do
        #it 'should return 1000000' do
          #expect(course_event.available_places).to eq 1000000
        #end

        #it 'should return limit_of_registrations' do
          #course = create(:course_event, store: store, limit_of_registrations: 15)
          #expect(course.available_places).to eq 15
        #end

        #it 'should return number_of_available places' do
          #course = create(:course_event, store: store, limit_of_registrations: 15)
          #create(:event_customer_participant, event: course)
          #expect(course.available_places).to eq 14
        #end
      #end

      #context '#in_the_past?' do
        #it 'should return true' do
          #expect(course_event.in_the_past?).to be_truthy
        #end

        #it 'should return false' do
          #course = create(:course_event, starts_at: Time.now + 1.days, ends_at: Time.now + 2.days)
          #expect(course.in_the_past?).to be_falsey
        #end
      #end

      #context '#make_cancel' do
        #it 'should update cancel field of course' do
          #expect(course_event.cancel?).to be_falsey
          #course_event.make_cancel
          #expect(course_event).to be_truthy
        #end
      #end

      #context '#no_registrations?' do
        #it 'should return true' do
          #expect(course_event.no_registrations?).to be_truthy
        #end

        #it 'should return false' do
          #create(:event_customer_participant, event: course_event)
          #course_event.reload
          #expect(course_event.no_registrations?).to be_falsey
        #end
      #end

      #context '#no_payments?' do
        #pending 'Need to write this test'
      #end

      #context '#can_change?' do
        #it 'should return true' do
          #expect(course_event.can_change?).to be_truthy
        #end

        #it 'should return false' do
          #course_event.make_cancel
          #expect(course_event.can_change?).to be_falsey
        #end
      #end

      #context '#notify_customer' do
        #before do
          #CompanyMailer.stub(:delay).and_return(CompanyMailer)
        #end

        #it 'should send email to customer' do
          #customer = create(:customer, company: store.company)
          #CompanyMailer.should_receive(:event_cancelled_no_payments).with(customer, course_event, 'super message')
          #course_event.notify_customer([customer], 'super message')
        #end
      #end

      #context '#get_refunded_event_customer_participants' do
        #pending 'Need to write test'
      #end

      #context 'get_paid_event_customer_participants' do
        #pending 'Need to write this test'
      #end

      #context '#full_name' do
        #it 'should return string name for course_event' do
          #expect(course_event.full_name).to eq "#{course_event.name} on #{course_event.starts_at.strftime("%a, #{course_event.starts_at.day.ordinalize} %B, %Y")}"
        #end
      #end

      #context '#event_short_time' do
        #it 'should return string with course_event time' do
          #expect(course_event.event_short_time).to eq "#{I18n.l(course_event.starts_at, formats: :default)} - #{I18n.l(course_event.ends_at, formats: :default)}"
        #end
      #end

      #context '#material_price_text' do
        #context 'when tax_rate inclusion' do
          #it 'should return empty string' do
            #expect(course_event.material_price_text).to eq ''
          #end

          #it 'should return material_price' do
            #cert_cost = create(:certification_level_cost_fixed, store: store)
            #course_event = create(:course_event, store: store, certification_level: cert_cost.certification_level)
            #expect(course_event.material_price_text).to eq "(#{I18n.t("activerecord.attributes.event.include_material_price")} $50.00)"
          #end
        #end

        #context 'when tax_rate exclusion' do
          #let(:store){ create(:store_tax_exclusion) }

          #it 'should return empty string' do
            #course_event = create(:course_event, store: store)
            #expect(course_event.material_price_text).to eq ''
          #end

          #it 'should return material_price' do
            #cert_cost = create(:certification_level_cost_fixed, store: store)
            #course_event = create(:course_event, store: store, certification_level: cert_cost.certification_level)
            #expect(course_event.material_price_text).to eq "(#{I18n.t("activerecord.attributes.event.include_material_price")} $57.50)"
          #end
        #end
      #end

      #context '#material_price' do
        #context 'when tax_rate inclusion' do
          #it 'should return 0' do
            #expect(course_event.material_price).to be_zero
          #end

          #it 'should return materia without tax_rate' do
            #cert_cost = create(:certification_level_cost_fixed, store: store)
            #course_event = create(:course_event, store: store, certification_level: cert_cost.certification_level)
            #expect(course_event.material_price).to eq 50
          #end
        #end

        #context 'when tax_rate exclusion' do
          #let(:store){ create(:store_tax_exclusion) }
          #let(:zero_tax_rate){ store.tax_rates.find_by_amount(0) }

          #it 'should return 0' do
            #course_event = create(:course_event, store: store)
            #expect(course_event.material_price).to be_zero
          #end

          #it 'should return 0 if material_price 0 and material_price_tax_rate not 0' do
            #cert_cost = create(:certification_level_cost_fixed, material_price: nil, store: store, material_price_tax_rate: zero_tax_rate)
            #course_event = create(:course_event, store: store, certification_level: cert_cost.certification_level)
            #expect(course_event.material_price).to eq 0
          #end

          #it 'should return material_price if material_price_tax_rate 0' do
            #cert_cost = create(:certification_level_cost_fixed, store: store, material_price_tax_rate: zero_tax_rate)
            #course_event = create(:course_event, store: store, certification_level: cert_cost.certification_level)
            #expect(course_event.material_price).to eq 50
          #end

          #it 'should return materia without material_price_tax_rate' do
            #cert_cost = create(:certification_level_cost_fixed, store: store)
            #course_event = create(:course_event, store: store, certification_level: cert_cost.certification_level)
            #expect(course_event.material_price).to eq 50 + (50 * 0.15)
          #end
        #end
      #end

      #context '#calc_dive_equipment' do
        #pending 'need to write tests'
      #end

      #context '#calc_rent_masks' do
        #pending 'need to write tests'
      #end

      #context '#calc_total_weight' do
        #it 'should re number' do
          #customer_1 = create(:customer, company: store.company, weight: 120)
          #customer_2 = create(:customer, company: store.company, weight: 79)
          #create(:event_customer_participant, customer: customer_1, event: course_event)
          #create(:event_customer_participant, customer: customer_2, event: course_event)
          #expect(course_event.calc_total_weight).to eq 199
        #end

        #it 'should return 0' do
          #expect(course_event.calc_total_weight).to be_zero
        #end
      #end

      #context '#trip?' do
        #it 'should return false' do
          #expect(course_event.trip?).to be_falsey
        #end
      #end

      #context '#event_time' do
        #it 'should return string with event start and end time' do
          #expect(course_event.event_time).to eq "#{I18n.l(course_event.starts_at, format: :default).capitalize} - #{I18n.l(course_event.ends_at, format: :default).capitalize}"
        #end
      #end

      #context '#course?' do
        #it 'should return true' do
          #expect(course_event.course?).to be_truthy
        #end
      #end

      #context '#unit_price' do
        #context 'tax rate inclusion' do
          #context 'customer is nil' do
            #it 'should return 0' do
              #course_event.update_attribute :price, nil
              #expect(course_event.unit_price).to be_zero
            #end

            #it 'should return @course_event price' do
              #cert_cost = create(:certification_level_cost_fixed, store: store)
              #course_event = create(:course_event, store: store, certification_level: cert_cost.certification_level, price: cert_cost.cost + cert_cost.material_price)
              #expect(course_event.unit_price).to eq cert_cost.cost + cert_cost.material_price
            #end
          #end

          #context 'customer is not local' do
            #it 'should return course_event price' do
              #customer = create(:customer, company: store.company)
              #cert_cost = create(:certification_level_cost_fixed, store: store)
              #course_event = create(:course_event, store: store, certification_level: cert_cost.certification_level, price: cert_cost.cost + cert_cost.material_price)
              #expect(course_event.unit_price(customer)).to eq cert_cost.cost + cert_cost.material_price
            #end
          #end
        #end

        #context 'tax rate exclusion' do
          #let(:store){ create(:store, tax_rate_inclusion: false) }

          #context 'customer is nil' do
            #it 'should return 0' do
              #course_event.update_attribute :price, nil
              #expect(course_event.unit_price).to be_zero
            #end

            #it 'should return @course_event price' do
              #cert_cost = create(:certification_level_cost_fixed, store: store)
              #course_event = create(:course_event, store: store, certification_level: cert_cost.certification_level, price: cert_cost.cost + cert_cost.cost * cert_cost.tax_rate.amount / 100 + cert_cost.material_price + cert_cost.material_price * cert_cost.material_price_tax_rate.try(:amount).to_f / 100)
              #expect(course_event.unit_price).to eq cert_cost.cost + cert_cost.cost * cert_cost.tax_rate.amount / 100 + cert_cost.material_price + cert_cost.material_price * cert_cost.material_price_tax_rate.try(:amount) / 100
            #end
          #end

          #context 'customer is not local' do
            #it 'should return @course_event price' do
              #customer = create(:customer, company: store.company)
              #cert_cost = create(:certification_level_cost_fixed, store: store)
              #course_event = create(:course_event, store: store, certification_level: cert_cost.certification_level, price: cert_cost.cost + cert_cost.cost * cert_cost.tax_rate.amount / 100 + cert_cost.material_price + cert_cost.material_price * cert_cost.material_price_tax_rate.try(:amount).to_f / 100)
              #expect(course_event.unit_price(customer)).to eq cert_cost.cost + cert_cost.cost * cert_cost.tax_rate.amount / 100 + cert_cost.material_price + cert_cost.material_price * cert_cost.material_price_tax_rate.try(:amount) / 100
            #end
          #end
        #end
      #end

      #context '#tax_rate_amount' do
        #context 'tax_rate_inclusion' do
          #before do
            #@cert_cost = create(:certification_level_cost_fixed, store: @store)
            #@course_event = create(:course_event, store: @store, certification_level: @cert_cost.certification_level, price: @cert_cost.cost + @cert_cost.material_price)
            #@child = @course_event.children.build(starts_at: Time.now + 5.days, ends_at: Time.now + 6.days)
            #@course_event.save
            #@customer = create(:customer, company: @store.company)
          #end

          #context 'customer nil' do
            #it 'should return 0' do
              #expect(@course_event.tax_rate_amount(nil, @course_event.price)).to be_zero
            #end

            #it 'should return 0 for child course_event' do
              #expect(@child.tax_rate_amount(nil, @course_event.price)).to be_zero
            #end
          #end

          #context 'customer is not nil' do
            #it 'should return tax rate amount' do
              #course_tax = 10.0 / 100
              #material_tax = 15.0 / 100
              #expect(@course_event.tax_rate_amount(@customer, @course_event.price).to_f.round(2)).to eq ((100 / (course_tax + 1) * course_tax  + 50 / (material_tax + 1) * material_tax)).round(2)
            #end

            #it 'should return 0 for child course_event' do
              #expect(@child.tax_rate_amount(@customer, @course_event.price)).to be_zero
            #end
          #end
        #end

        #context 'tax_rate_exclusion' do
          #before do
            #@store = create(:store, tax_rate_inclusion: false)
            #@cert_cost = create(:certification_level_cost_fixed, store: @store)
            #@course_event = create(:course_event, store: @store, certification_level: @cert_cost.certification_level, price: @cert_cost.cost + @cert_cost.material_price)
            #@child = @course_event.children.build(starts_at: Time.now + 5.days, ends_at: Time.now + 6.days)
            #@course_event.save
            #@customer = create(:customer, company: @store.company)
          #end

          #context 'customer nil' do
            #it 'should return 0' do
              #expect(@course_event.tax_rate_amount(nil, @course_event.price)).to be_zero
            #end

            #it 'should return 0 for child course_event' do
              #expect(@child.tax_rate_amount(nil, @course_event.price)).to be_zero
            #end
          #end

          #context 'customer is not nil' do
            #it 'should return tax rate amount' do
              #expect(@course_event.tax_rate_amount(@customer, @course_event.price).to_f).to eq 100 * 10 / 100 + 50 * 15 / 100.0
            #end

            #it 'should return 0 for child course_event' do
              #expect(@child.tax_rate_amount(@customer, @course_event.price)).to be_zero
            #end
          #end
        #end
      #end

      #context '#line_item_price' do
        #context 'tax_rate inclusion' do
          #before do
            #@cert_cost = create(:certification_level_cost_fixed, store: @store)
            #@customer = create(:customer, company: @store.company)
            #@course_event = create(:course_event, store: @store, certification_level: @cert_cost.certification_level, price: @cert_cost.cost + @cert_cost.material_price)
            #@child = @course_event.children.build(starts_at: Time.now + 5.days, ends_at: Time.now + 6.days)
            #@course_event.save
          #end

          #it 'should return unit_price for parent course_event' do
            #expect(@course_event.line_item_price(@customer)).to eq 150
          #end

          #it 'should return 0 for child course_event' do
            #expect(@child.line_item_price(@customer)).to be_zero
          #end
        #end

        #context 'tax_rate exclusion' do
          #before do
            #@store = create(:store, tax_rate_inclusion: false)
            #@cert_cost = create(:certification_level_cost_fixed, store: @store)
            #@customer = create(:customer, company: @store.company)
            #@course_event = create(:course_event, store: @store, certification_level: @cert_cost.certification_level, price: @cert_cost.cost + @cert_cost.cost * @cert_cost.tax_rate.amount / 100  + @cert_cost.material_price + @cert_cost.material_price * @cert_cost.material_price_tax_rate.try(:amount).to_f / 100)
            #@child = @course_event.children.build(starts_at: Time.now + 5.days, ends_at: Time.now + 6.days)
            #@course_event.save
          #end

          #it 'should return unit_price for parent course_event' do
            #expect(@course_event.line_item_price(@customer)).to eq 185
          #end

          #it 'should return 0 for child course_event' do
            #expect(@child.line_item_price(@customer)).to be_zero
          #end
        #end
      #end

      #context '#can_be_deleted?' do
        #it 'should return true' do
          #expect(@course_event.can_be_deleted?).to be_true
        #end

        #it 'should return false if event has staffs' do
          #create(:event_user_participant, event: @course_event, user: @store.company.users.first)
          #@course_event.reload
          #expect(@course_event.can_be_deleted?).to be_false
        #end

        #it 'should return false if event has customer' do
          #customer = create(:customer, company: @store.company)
          #create(:event_customer_participant, event: @course_event, customer: customer)
          #@course_event.reload
          #expect(@course_event.can_be_deleted?).to be_false
        #end
      #end

      #context '#recurring?' do
        #it 'should return false' do
          #expect(@course_event.recurring?).to be_false
        #end

        #context 'with child' do
          #before do
            #@child = @course_event.children.build(starts_at: Time.now + 5.days, ends_at: Time.now + 6.days)
            #@course_event.save
          #end

          #it 'should return true for course_event' do
            #expect(@course_event.recurring?).to be_true
          #end

          #it 'should return true for child course_event' do
            #expect(@child.recurring?).to be_true
          #end
        #end
      #end

      #context '#recurring_child?' do
        #it 'should return false' do
          #expect(@course_event.recurring_child?).to be_false
        #end

        #context 'with child' do
          #before do
            #@child = @course_event.children.build(starts_at: Time.now + 5.days, ends_at: Time.now + 6.days)
            #@course_event.save
          #end

          #it 'should return true for child' do
            #expect(@child.recurring_child?).to be_true
          #end
        #end
      #end

      #context '#recurring_parent?' do
        #it 'should return false' do
          #expect(@course_event.recurring_parent?).to be_false
        #end

        #it 'should return true' do
          #@course_event.children.build(starts_at: Time.now + 5.days, ends_at: Time.now + 6.days)
          #@course_event.save
          #@course_event.reload
          #expect(@course_event.recurring_parent?).to be_true
        #end
      #end

      #context '#available_staffs' do
        #pending 'need to write tests'
      #end
    end
  end
end
