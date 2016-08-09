class CertificationLevelMembership < ActiveRecord::Base
  VALID_MEMBERABLE_TYPES = %w(Customer User)
  has_paper_trail

  belongs_to :certification_level, include: :certification_agency
  belongs_to :memberable, polymorphic: true

  has_one :certification_agency, through: :certification_level

  validates :memberable_type, inclusion: { in: VALID_MEMBERABLE_TYPES }
  validates :membership_number, length: { maximum: 255 }, allow_blank: true
  validates :certification_level_id, existence: true, uniqueness: { scope: [ :memberable_id, :memberable_type ] }
  validates :certification_date, timeliness: { type: :date }, allow_blank: true
  validates :primary, inclusion: { in: [true, false] }

  validate :primary_should_be_one, on: :update

  scope :primaries, ->{ where(primary: true) }

  attr_accessor :certification_agency_id
  attr_accessible :certification_agency_id, :certification_level_id, :certification_date, :membership_number, :primary, :certification_date

  def to_s
    [self.certification_agency.try(:name), self.certification_level.try(:name), "##{self.membership_number}", self.certification_date.blank? ? nil : "(#{self.certification_date})"].join(' ')
  end

  def certification_agency_export
    self.certification_agency.try(:name)
  end

  def certification_level_export
    self.certification_level.try(:name)
  end

  def membership_number_export
    self.membership_number.blank? ? nil : self.membership_number
  end

  def certification_date_export
    self.certification_date.blank? ? nil : self.certification_date
  end

  private
  def primary_should_be_one
    errors.add(:primary, I18n.t('models.certification_level_membership.should_be_one')) if memberable.certification_level_memberships.primaries.count > 1
  end
end
