class Attachment < ActiveRecord::Base
  has_paper_trail

  ATTACHABLE_TYPES = ["Incident", "Note"]

  belongs_to :attachable, polymorphic: true

  attr_accessible :data

  has_attached_file :data, url: "/files/:attachable_type/:attachable_id/:filename"

  validates_attachment_size :data, less_than: 2.megabytes

  validates :attachable_id, uniqueness: { scope: :attachable_type }
  validates :attachable_type, inclusion: { in: ATTACHABLE_TYPES }

  scope :images, where{data_content_type.matches "image/%"}

  Paperclip.interpolates :attachable_type do |attachment, style|
    attachment.instance.attachable_type.underscore
  end

  Paperclip.interpolates :attachable_id do |attachment, style|
    attachment.instance.attachable_id
  end

  def short_content_type
    data.content_type[/.*\/(.*)/, 1]
  end
end
