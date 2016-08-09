class CertificationAgency < ActiveRecord::Base
  include CurrentStoreInfo
  has_paper_trail

  attr_accessible :certification_levels_attributes, :name

  with_options dependent: :destroy do |o|
    o.has_many :certification_levels
    o.has_one :logo, as: :imageable, class_name: "Image"
  end

  def certification_levels_with_cost
    certification_levels.with_cost(current_store_info.id)
  end

  def all_certification_levels
    certification_levels.added_by_admin + certification_levels.where(store_id: current_store_info.id)
  end

  accepts_nested_attributes_for :logo, allow_destroy: true
  accepts_nested_attributes_for :certification_levels, allow_destroy: true

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true

  after_save :create_image_if_not_exists
  before_destroy :should_has_no_certification_levels

  private
  def create_image_if_not_exists
    self.build_logo and self.save if self.logo.blank?
  end

  def should_has_no_certification_levels
    errors.add :base, I18n.t('models.certification_agency.should_has_no_certification_levels') unless certification_levels.empty?
    errors.blank?
  end
end
