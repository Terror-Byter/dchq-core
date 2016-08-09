require 'spec_helper'

describe Address do
  context '#DB' do
    it { expect(subject).to have_db_index([:addressable_id, :addressable_type]) }
  end

  context '#Associations' do
    it { expect(subject).to belong_to(:addressable) }
  end

  context '#Validations' do
    it { expect(subject).to ensure_length_of(:first).is_at_most(255) }
    it { expect(subject).to allow_value(nil, '').for(:first) }
    it { expect(subject).to ensure_length_of(:second).is_at_most(255) }
    it { expect(subject).to allow_value(nil, '').for(:second) }
    it { expect(subject).to ensure_length_of(:city).is_at_most(255) }
    it { expect(subject).to allow_value(nil, '').for(:city) }
    it { expect(subject).to ensure_length_of(:state).is_at_most(255) }
    it { expect(subject).to allow_value(nil, '').for(:state) }
    it { expect(subject).to ensure_length_of(:post_code).is_at_most(255) }
    it { expect(subject).to allow_value(nil, '').for(:post_code) }
    it { expect(subject).to ensure_inclusion_of(:country_code).in_array(CountrySelect::COUNTRIES.keys) }
    it { expect(subject).to allow_value(nil, '').for(:country_code) }
  end

  context '#Methods' do
    let(:address){ create(:address) }

    context '#country' do
      it 'should return empty result' do
        address.update_attributes country_code: nil
        expect(address.country).to be_blank
      end

      it 'should return country name' do
        expect(address.country).to eq 'United States'
      end
    end

    context '#country_name' do
      it 'should return empty result' do
        address.update_attributes country_code: nil
        expect(address.country_name).to be_blank
      end

      it 'should return country name' do
        expect(address.country_name).to eq 'United States'
      end
    end

    context '#downcase_country_code' do
      it 'should downcase country code' do
        address = build(:address, country_code: 'AU')
        address.valid?
        expect(address.country_code).to eq 'au'
      end
    end

    context 'full_address' do
      it 'should return address' do
        address = build(:address, first: 'A', second: 'B', city: 'C', state: 'D', country_code: 'us', post_code: '1234')
        expect(address.full_address).to eq 'A B C D 1234 United States'
      end

      it 'should return address even if address has a few options' do
        address = build(:address, first: 'A', second: '', city: '', state: '', country_code: 'us', post_code: '1234')
        expect(address.full_address).to eq 'A 1234 United States'
      end
    end
  end
end
