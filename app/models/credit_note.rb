class CreditNote < ActiveRecord::Base
  has_paper_trail

  belongs_to :customer, with_deleted: true
  belongs_to :sale

  validates :customer, presence: true
  validates :sale, presence: true
  validates :initial_value, numericality: { greater_than_or_equal_to: 0.0 }
  validates :remaining_value, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: :initial_value }

  attr_accessible :sale_id, :customer_id, :initial_value, :remaining_value

  scope :ordered, ->{ order('created_at DESC') }
  include
end
