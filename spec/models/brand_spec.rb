require 'spec_helper'

describe Brand do
  context '#Associations' do
    it { expect(subject).to have_many(:rental_products).dependent(:destroy) }
  end
end
