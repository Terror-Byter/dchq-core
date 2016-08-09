class Till < ActiveRecord::Base
  has_paper_trail

  belongs_to :store
  belongs_to :user, with_deleted: true

  attr_accessible :store_id, :store, :user, :user_id, :amount, :notes, :take_out
  with_options presence: true do |t|
    t.validates :store
    t.validates :user
    t.validates :amount
  end
  validates :notes, length: { maximum: 65536 }
  validates :take_out, inclusion: { in: [true, false] }

  before_validation :add_default_amount

  private
  def add_default_amount
    self.amount = 0 if amount.blank?
  end
end
