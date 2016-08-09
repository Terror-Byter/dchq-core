class Incident < ActiveRecord::Base
  has_paper_trail

  belongs_to :customer, with_deleted: true
  belongs_to :creator, class_name: "User"

  has_one :attachment, as: :attachable, dependent: :destroy

  accepts_nested_attributes_for :attachment

  validates :customer, presence: true
  validates :creator, existence: true
  validates :description, presence: true, length: { maximum: 65535 }
  validates_date :occurred_on, on_or_before: :today, allow_blank: true

  attr_accessible :attachment_attributes, :customer_id, :creator_id, :description, :occurred_on
end
