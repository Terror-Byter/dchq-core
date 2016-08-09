class Note < ActiveRecord::Base
  has_paper_trail

  belongs_to :notable, polymorphic: true

  belongs_to :creator, class_name: "User", with_deleted: true

  has_one :attachment, as: :attachable, dependent: :destroy

  accepts_nested_attributes_for :attachment

  validates :creator, presence: true, on: :update
  validates :description, presence: true, length: { maximum: 65536 }

  attr_accessible :attachment_attributes, :creator_id, :description, :creator
end
