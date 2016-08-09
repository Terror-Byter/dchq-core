require 'spec_helper'

describe Stores::Boat do
  it { should have_db_index(:store_id) }

  context 'Associations' do
    it { should belong_to(:store) }
    it { should have_many(:events) }
    it { should have_many(:event_customer_participants).through(:events) }
    it { should have_many(:event_user_participants).through(:events) }
  end

  context 'Mass Assing Attributes' do
    it { should allow_mass_assignment_of(:color) }
    it { should allow_mass_assignment_of(:name) }
  end

  context 'Validations' do
    it { should validate_presence_of(:name) }
    it { should ensure_length_of(:name).is_at_most(255) }
    it { should validate_presence_of(:store) }
    it { should validate_presence_of(:color) }
    it { should allow_value('123321', 'acb313', 'aaafff').for(:color)}
    it { should_not allow_value('zxs', '1213', 'aaafxff', 'xsaxxc').for(:color)}
  end
end
