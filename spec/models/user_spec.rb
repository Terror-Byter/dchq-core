require 'spec_helper'

describe User do
  context '#Associations' do
    it { expect(subject).to have_many(:rentals) }
  end
end
