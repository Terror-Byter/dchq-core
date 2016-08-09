class Supplier < ActiveRecord::Base
  include PgSearch

  pg_search_scope :search, against: [:name],
                           using: {
                             tsearch: {prefix: true, any_word: true },
                             trigram: { } },
                           ignoring: :accents

  acts_as_taggable
  acts_as_paranoid
  has_paper_trail

  belongs_to :company

  has_one :address, as: :addressable
  has_one :logo, as: :imageable, class_name: "Image"
  has_many :notes, as: :notable
  has_many :business_contacts
  has_many :products

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :logo, allow_destroy: true

  attr_accessible :address_attributes, :logo_attributes, :company_id, :name, :telephone, :email, :tag_list,
                  :company

  validates :company, existence: true

  with_options length: { maximum: 255 } do |l|
    l.validates :name, presence: true
    l.validates :telephone, format: { with: /\A\+?[0-9\-\(\) ]*\Z/ }
  end
  validates :email, email_format: true, allow_blank: true

  validate :verify_email_for_fake

  after_create :add_logo_and_address

  class << self
    def field_names
      {
        name:         I18n.t("activerecord.attributes.supplier.name"),
        telephone:    I18n.t("activerecord.attributes.supplier.telephone"),
        email:        I18n.t("activerecord.attributes.supplier.email"),
        first:        I18n.t("activerecord.attributes.address.first"),
        second:       I18n.t("activerecord.attributes.address.second"),
        city:         I18n.t("activerecord.attributes.address.city"),
        state:        I18n.t("activerecord.attributes.address.state"),
        country_code: I18n.t("activerecord.attributes.address.country_code"),
        post_code:    I18n.t("activerecord.attributes.address.post_code")
      }
    end
  end

  def can_be_deleted?
    products.blank?
  end

  alias_attribute :label, :name

  private
  def verify_email_for_fake
    return if self.email.blank?
    result = EmailVeracity::Address.new(self.email)
    errors.add(:email, I18n.t('models.supplier.email_is_fake')) unless result.valid?
  end

  def add_logo_and_address
    create_logo unless logo
    create_address unless address
  end
end
