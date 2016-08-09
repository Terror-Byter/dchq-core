class CourseEvent < Event
  belongs_to :certification_level, include: [:certification_agency]
  belongs_to :parent, class_name: "CourseEvent", foreign_key: 'parent_id'

  has_many :children, class_name: 'CourseEvent', foreign_key: "parent_id", dependent: :destroy

  attr_accessor :certification_agency_id

  attr_accessible :certification_agency_id, :children_attributes, :all_day

  accepts_nested_attributes_for :children, allow_destroy: true, reject_if: ->(u){ u[:starts_at].blank? || u[:ends_at].blank? }

  validates :certification_level, presence: true
  before_validation :copy_parent_course_to_child
  after_create :copy_staffs_to_new_days, :copy_ecps_to_new_days
  after_save :add_name
  after_save :add_child_names, only: [:update], if: ->(c){ c.parent? }

  scope :parent, ->{ where(parent_id: nil) }

  def certification_agency
    @certification_agency ||= certification_level.try(:certification_agency)
  end

  def cert
    "#{certification_agency.name}, #{certification_level.name}"
  end

  def parent?
    parent_id.nil?
  end

  private
  def copy_parent_course_to_child
    children.each do |child|
      child[:certification_level_id] = certification_level_id
      child[:limit_of_registrations] = limit_of_registrations
      child[:instructions]           = instructions
      child[:notes]                  = notes
      child[:private]                = self.private
      child[:enable_booking]         = enable_booking
      child[:price]                  = 0
      child[:event_type_id]          = event_type_id
      child[:frequency]              = frequency
      child[:store_id]               = store_id
    end
  end

  def copy_staffs_to_new_days
    return if !event_user_participants.empty? || parent?
    parent.event_user_participants.map{ |eup| self.event_user_participants.create(user_id: eup.user_id, role: eup.role) }
  end

  def copy_ecps_to_new_days
    return if !event_customer_participants.empty? || parent?
    parent.event_customer_participants.each do |ecp|
      new_ecp = ecp.dup
      new_ecp[:event_id] = self.id
      new_ecp[:event_user_participant_id] = EventUserParticipant.find_by_event_id_and_user_id(self.id, ecp.event_user_participant.user.id).id if ecp.event_user_participant
      new_ecp.save!
    end
  end

  def add_name
    update_column(
      :name,
      [
        certification_agency.try(:name),
        "#{certification_level.try(:name)} #{I18n.t('dive_course')}",
        "#{I18n.t('day')} #{parent? ? 1 : parent.children.order(:starts_at).index(self) + 2}"
      ].join(' - ')
    )
  end

  def add_child_names
    children.each(&:save)
  end
end
