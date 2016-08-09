class AllPayment < ActiveRecord::Base
  has_paper_trail

  belongs_to :cashier, class_name: "User", with_deleted: true
  belongs_to :payment_method, with_deleted: true

  with_options existence: true do |e|
    e.validates :cashier
    e.validates :payment_method
  end

  validates :amount, presence: true, numericality: true

  scope :not_new, ->{ where{ (created_at.not_eq nil) } }
  scope :today, ->(time){ where(created_at: time.beginning_of_day..time) }
  scope :calc, ->(pm){ where(payment_method_id: pm) }
  scope :for_last_working_day, ->(time){ where{ (updated_at.gteq time[:open_at]) & (updated_at.lteq time[:close_at]) } }

  attr_accessor :amount_for_search
  attr_accessible :cashier_id, :customer_id, :amount, :payment_method_id, :amount_for_search, :payment_transaction

  class << self
    def tendered
      joins(:payment_method).group('payment_methods.name').sum(:amount)
    end
  end
end
