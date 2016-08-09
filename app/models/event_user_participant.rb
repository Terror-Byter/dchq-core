class EventUserParticipant < ActiveRecord::Base
  has_paper_trail

  belongs_to :event, with_deleted: true
  belongs_to :user, with_deleted: true

  has_many :event_customer_participants

  attr_accessible :role, :user_id, :_destroy

  validates :event, presence: true, on: :update
  validates :user_id, presence: true, uniqueness: { scope: :event_id }
  validates :role, presence: true, length: { maximum: 255 }

  validate :user_must_belong_to_event_company

  attr_accessor :include_to_recuring_events

  after_create :add_staff_to_children_events

  private
  def user_must_belong_to_event_company
    errors.add(:user_id, :must_belong_to_event_company) unless self.user.nil? || self.event.nil? || self.user.try(:company) == self.event.store.try(:company)
  end

  def add_staff_to_children_events
    if event.course?
      event.children.map { |child_course| child_course.event_user_participants.create(user_id: user_id, role: role) }
    else
      return if include_to_recuring_events != "1" || event.course?
      event.get_future_recurring_events.map{ |u| u.event_user_participants.create(user_id: user_id, role: role) }
    end
  end
end
