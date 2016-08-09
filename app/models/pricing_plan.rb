class PricingPlan < ActiveRecord::Base
  has_paper_trail

  has_many :companies

  attr_accessible :name, :description, :price, :number_of_users, :number_of_customers, :number_of_shops, :billing_period, :visible

  validates :name, presence: true
  validates :price,                presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :number_of_users,      presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :number_of_customers,  presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :number_of_shops,      presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :billing_period,       presence: true, numericality: true, inclusion: { in: [30, 365] }

  after_create :add_plan_on_stripe
  after_destroy :delete_plan_from_stripe

  scope :visible, ->{ where(visible: true) }
  scope :invisible, ->{ where(visible: false) }

  attr_accessor :init

  def self.turtle
    visible.where( name: "Turtle").first
  end

  def self.interval_to_numbers interval
    interval.eql?("month") ? 30 : 365
  end

  def billing_period_to_name
    billing_period.eql?(30) ? "month" : "year"
  end

  private
  def add_plan_on_stripe
    Stripe::Plan.create( amount: ( price * 100 ).to_i , interval: billing_period_to_name, name: name, currency: 'gbp', id: id) unless init.present?
  end

  def delete_plan_from_stripe
    begin
      plan = Stripe::Plan.retrieve("#{ id }")
      plan.delete
    rescue
    end
  end

end
