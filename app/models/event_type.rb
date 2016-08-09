class EventType < ActiveRecord::Base
  has_paper_trail

  has_many :events

  attr_accessible :name

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true

  before_destroy :must_not_destroy_when_events_exist

  scope :without_course, ->{ where{ name.not_eq 'Course' } }

  protected

  def must_not_destroy_when_events_exist
    unless events.empty?
      errors.add_to_base(:destroy_when_events_exist)
      false
    else
      true
    end
  end

end
