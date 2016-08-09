require 'spec_helper'

describe PaymentMethod do
  context '#Associations' do
    it { expect(subject).to have_many(:rental_payments) }
  end
end
