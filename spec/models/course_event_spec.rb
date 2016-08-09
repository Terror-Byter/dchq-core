require 'spec_helper'

describe CourseEvent do
  context 'Associations' do
    it { expect(subject).to belong_to(:certification_level) }
    it { expect(subject).to belong_to(:parent).class_name('CourseEvent').with_foreign_key('parent_id') }
    it { expect(subject).to have_many(:children).class_name('CourseEvent').with_foreign_key('parent_id').dependent(:destroy) }
  end

  context 'Mass-Asssign Protection' do
    it { expect(subject).to allow_mass_assignment_of(:certification_agency_id) }
    it { expect(subject).to allow_mass_assignment_of(:children_attributes) }
  end

  context 'NestedAttributes' do
    it { expect(subject).to accept_nested_attributes_for(:children).allow_destroy(true) }
  end

  context 'Validation' do
    it { validate_presence_of(:certification_level) }
  end

  context '#Methods' do
    let(:store){ create(:store) }
    let(:course_event){ create(:course_event, store: store) }
    let(:child_event){ course_event.children.create(starts_at: Time.now + 10.hours, ends_at: Time.now + 16.hours) }

    context '#name' do
      it 'should return course public name' do
        expect(course_event.name).to eq "#{course_event.certification_agency.name} - #{course_event.certification_level.name} #{I18n.t('dive_course')} - #{I18n.t('day')} 1"
      end
    end

    context '#cert' do
      it 'should return certification_agency name and certification_level name' do
        expect(course_event.cert).to eq "#{course_event.certification_agency.name}, #{course_event.certification_level.name}"
      end
    end

    context '#parent?' do
      it 'should return true' do
        expect(course_event.parent?).to be_truthy
      end

      it 'should return false' do
        expect(child_event.parent?).to be_falsey
      end
    end
  end
end
