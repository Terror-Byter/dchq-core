class PaymentCredential < ActiveRecord::Base
  has_paper_trail

  belongs_to :company
  attr_accessible :paypal_login, :paypal_password, :paypal_signature, :stripe_secret_key, :stripe_publishable_key,
                  :epay_merchant_number ,:epay_password, :epay_currency

  validates :company,                presence: true
  validates :stripe_secret_key,      presence: true, unless: ->(u){ u.stripe_publishable_key.blank? }
  validates :stripe_publishable_key, presence: true, unless: ->(u){ u.stripe_secret_key.blank? }
  validates :paypal_login,           presence: true, unless: ->(u){ u.paypal_password.blank? && u.paypal_signature.blank? }
  validates :paypal_password,        presence: true, unless: ->(u){ u.paypal_login.blank? && u.paypal_signature.blank? }
  validates :paypal_signature,       presence: true, unless: ->(u){ u.paypal_login.blank? && u.paypal_password.blank? }
  validates :epay_merchant_number,   presence: true, unless: ->(u){ u.epay_merchant_number.blank? }
  validates :epay_password,          presence: true, unless: ->(u){ u.epay_password.blank? }
  validates :epay_currency,          presence: true, unless: ->(u){ u.epay_currency.blank? }
end
