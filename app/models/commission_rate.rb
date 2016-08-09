class CommissionRate < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail

  belongs_to :store

  attr_accessible :amount

  validates :store_id, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, uniqueness: { scope: :store_id }

  def default?
    self.store && self.store.commission_rates.first.eql?(self)
  end

  def formatted_amount
    "#{ amount }%"
  end
end
