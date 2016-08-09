class BusinessContact < ActiveRecord::Base
  include CurrentUserInfo

  acts_as_taggable
  acts_as_paranoid
  has_paper_trail

  belongs_to :supplier
  has_one :company, through: :supplier

  has_one :avatar, as: :imageable, class_name: "Image", dependent: :destroy
  has_many :notes, as: :notable

  attr_accessible :given_name, :family_name, :email, :telephone, :position, :tag_list, :avatar_attributes
  accepts_nested_attributes_for :avatar, allow_destroy: true

  validates :supplier, existence: true

  with_options length: {maximum: 255} do |l|
    l.validates :given_name, presence: true
    l.validates :family_name, presence: true
    l.validates :telephone, format: {with: /\A\+?[0-9\-\(\) ]*\Z/ }
    l.validates :email, email_format: true
    l.validates :position
  end

  # TODO: only one business_contact can be primary
  validates :primary, inclusion: { in: [true, false] }

  class << self
    def field_names
      {
        supplier_id: I18n.t("activerecord.attributes.business_contact.supplier_id"),
        given_name:  I18n.t("activerecord.attributes.business_contact.given_name"),
        family_name: I18n.t("activerecord.attributes.business_contact.family_name"),
        email:       I18n.t("activerecord.attributes.business_contact.email"),
        telephone:   I18n.t("activerecord.attributes.business_contact.telephone"),
        position:    I18n.t("activerecord.attributes.business_contact.position"),
        primary:     I18n.t("activerecord.attributes.business_contact.primary")
      }
    end
  end

  def full_name
    self.instance_eval{"#{given_name} #{family_name}"}
  end
end
