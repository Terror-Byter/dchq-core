class PaymentMethod < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail

  belongs_to :store
  has_many :payments
  has_many :rental_payments

  attr_accessible :name, :xero_code

  validates :store_id, existence: true
  validates :name, presence: true, uniqueness: { scope: :store_id }

  default_scope ->{ order('id ASC') }
  scope :paypal, ->{ where(name: "Paypal") }
  scope :stripe, ->{ where(name: "Credit Card") }
  scope :epay, ->{ where(name: "Epay")}

  def default?
    self.store && self.store.payment_methods.first.eql?(self)
  end
end
