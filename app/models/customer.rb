class Customer < ActiveRecord::Base
  acts_as_taggable
  acts_as_paranoid
  has_paper_trail

  include CurrentUserInfo
  include MailchimpActiveRecord
  include PgSearch

  pg_search_scope :search, against: [:given_name, :family_name],
                           using: {
                             tsearch: {prefix: true, any_word: true },
                             trigram: { } }

  belongs_to :company
  belongs_to :customer_experience_level

  has_one :address, as: :addressable, autosave: true
  has_one :avatar, as: :imageable, class_name: "Image"
  has_many :certification_level_memberships, as: :memberable
  has_many :incidents
  has_many :notes, as: :notable
  has_many :sale_customers
  has_many :sales, through: :sale_customers, uniq: true
  has_many :event_customer_participants
  has_many :credit_notes
  has_many :custom_fields, class_name: "Stores::CustomField"
  has_many :services
  has_many :events, through: :event_customer_participants
  has_many :rentals

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :avatar, allow_destroy: true
  accepts_nested_attributes_for :certification_level_memberships, allow_destroy: true, reject_if: ->(pm){ pm[:certification_level_id].blank? }
  accepts_nested_attributes_for :custom_fields, allow_destroy: true, reject_if: ->(pm){ pm[:name].blank? }
  accepts_nested_attributes_for :notes, allow_destroy: true, reject_if: ->(pm){ pm[:description].blank? }

  attr_accessible :address_attributes, :avatar_attributes, :certification_level_memberships_attributes,
                  :company_id, :customer_experience_level_id,
                  :given_name, :family_name, :born_on, :default_discount_level, :source,
                  :telephone, :mobile_phone, :email, :fins, :bcd, :wetsuit,
                  :last_dive_on, :number_of_logged_dives, :tag_list, :hotel_name, :room_number, :gender, :credit_note, :emergency_contact_details, :weight, :fins_own,
                  :bcd_own, :wetsuit_own, :mask_own, :regulator_own, :custom_fields_attributes, :notes_attributes,
                  :send_event_related_emails, :tax_id, :zero_tax_rate, :booked, :deleted_at

  attr_accessor :booked

  validates :company, existence: true

  with_options allow_blank: true do |o|
    o.validates_date :born_on, before: :today, after: :oldest_age
    o.validates_date :last_dive_on, on_or_before: :today, after: :born_on
    o.validates :hotel_name, length: { maximum: 255 }
    o.validates :room_number, length: { maximum: 10 }
    o.validates :tax_id, length: { maximum: 255 }
    o.validates :mobile_phone, length: { maximum: 255 }
    o.validates :default_discount_level, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
    o.validates :telephone, length: { maximum: 255 }
    o.validates :customer_experience_level, existence: true
    o.validates :number_of_logged_dives, numericality: { greater_than_or_equal_to: 0 }
    o.validates :credit_note, presence: true, numericality: { greater_than_or_equal_to: 0 }
    o.validates :emergency_contact_details, length: { maximum: 255 }
    o.validates :weight, length: { maximum: 255 }
    o.validates :mask_own, inclusion: { in: [true, false] }
    o.validates :regulator_own, inclusion: { in: [true, false] }
  end

  with_options inclusion: { in: [true, false] } do |v|
    v.validates :fins_own, allow_blank: true
    v.validates :bcd_own, allow_blank: true
    v.validates :wetsuit_own, allow_blank: true
    v.validates :send_event_related_emails
  end

  with_options length: { maximum: 255 } do |l|
    l.with_options presence: true do |p|
      p.validates :given_name
      p.validates :family_name
    end
  end

  scope :exclude_with,    ->(sale){ where(:id.not_in => Sale.last.sale_customers.map(&:id)) }
  scope :without_walk_in, ->{ where{ (given_name.not_eq 'Walk') & (family_name.not_eq 'In') } }
  scope :with_email,      ->{ where{ (email.not_eq nil) & (email.not_eq '')  } }

  def self.field_names
    { customer_experience_level_id: I18n.t("activerecord.attributes.customer.customer_experience_level_id"),
      given_name:                   I18n.t("activerecord.attributes.customer.given_name"),
      family_name:                  I18n.t("activerecord.attributes.customer.family_name"),
      default_discount_level:       I18n.t("activerecord.attributes.customer.default_discount_level"),
      source:                       I18n.t("activerecord.attributes.customer.source"),
      telephone:                    I18n.t("activerecord.attributes.customer.telephone"),
      mobile_phone:                 I18n.t("activerecord.attributes.customer.mobile_phone"),
      email:                        I18n.t("activerecord.attributes.customer.email"),
      fins:                         I18n.t("activerecord.attributes.customer.fins"),
      bcd:                          I18n.t("activerecord.attributes.customer.bcd"),
      wetsuit:                      I18n.t("activerecord.attributes.customer.wetsuit"),
      number_of_logged_dives:       I18n.t("activerecord.attributes.customer.number_of_logged_dives"),
      born_on:                      I18n.t("activerecord.attributes.customer.born_on"),
      last_dive_on:                 I18n.t("activerecord.attributes.customer.last_dive_on"),
      hotel_name:                   I18n.t("activerecord.attributes.customer.hotel_name"),
      room_number:                  I18n.t("activerecord.attributes.customer.room_number"),
      first:                        I18n.t("activerecord.attributes.address.first"),
      second:                       I18n.t("activerecord.attributes.address.second"),
      city:                         I18n.t("activerecord.attributes.address.city"),
      state:                        I18n.t("activerecord.attributes.address.state"),
      country_code:                 I18n.t("activerecord.attributes.address.country_code"),
      post_code:                    I18n.t("activerecord.attributes.address.post_code"),
      gender:                       I18n.t("activerecord.attributes.customer.gender"),
      tags:                         I18n.t("activerecord.attributes.customer.tag_list"),
      certification_agency_id:      I18n.t("activerecord.attributes.certification_level_membership.certification_agency_id"),
      certification_level_id:       I18n.t("activerecord.attributes.certification_level_membership.certification_level_id"),
      membership_number:            I18n.t("activerecord.attributes.certification_level_membership.membership_number"),
      certification_date:           I18n.t("activerecord.attributes.certification_level_membership.certification_date"),
      primary:                      I18n.t("activerecord.attributes.certification_level_membership.primary"),
      emergency_contact_details:    I18n.t("activerecord.attributes.customer.emergency_contact_details"),
      fins_own:                     I18n.t("activerecord.attributes.customer.fins_own"),
      bcd_own:                      I18n.t("activerecord.attributes.customer.bcd_own"),
      wetsuit_own:                  I18n.t("activerecord.attributes.customer.wetsuit_own"),
      mask_own:                     I18n.t("activerecord.attributes.customer.mask_own"),
      regulator_own:                I18n.t("activerecord.attributes.customer.regulator_own"),
      weight:                       I18n.t("activerecord.attributes.customer.weight"),
      custom_fields:                I18n.t("activerecord.attributes.customer.custom_fields"),
      notes:                        I18n.t("activerecord.attributes.customer.notes"),
      send_event_related_emails:    I18n.t("activerecord.attributes.customer.send_event_related_emails"),
      tax_id:                       I18n.t("activerecord.attributes.customer.tax_id"),
      zero_tax_rate:                I18n.t("activerecord.attributes.customer.zero_tax_rate")
    }
  end

  class << self
    def genders
      { male:   I18n.t("activerecord.attributes.customer.genders.male"),
        female: I18n.t("activerecord.attributes.customer.genders.female")}
    end

    def fins_collection
      %w(Jr 4/5 6/7 8/9 10/11 12/13 14/15)
    end

    def bcd_collection
      %w(Jr Xs S M L XL)
    end
  end

  def full_name
    "#{given_name} #{family_name}"
  end
  alias :label :full_name

  def purchase_amount
    sales.sum(:grand_total)
  end

  def first_sale_at
    sales.minimum(:created_at).to_s(:month_with_year)
  end

  def last_sale_at
    sales.maximum(:created_at).to_s(:month_with_year)
  end

  def apply_default_discount_level?(sale_discount)
    default_discount_level > sale_discount.to_i
  end

  def walk_in?
    email.eql? Figaro.env.walk_in_email
  end

  def has_credit_note?
    !credit_note.zero?
  end

  def emergency_contact_details
    self[:emergency_contact_details].blank? ? "-" : self[:emergency_contact_details]
  end

  def custom_fields_for_export
    value = []
    custom_fields.each do |custom_field|
      value << "#{custom_field.name}:#{custom_field.value}"
    end
    value.join("|")
  end

  def notes_for_export
    notes.map(&:description).join("|")
  end

  def last_cert
    return "-" if certification_level_memberships.blank?
    certification_level_membership_last = certification_level_memberships.last
    "#{certification_level_membership_last.certification_agency.try(:name)}, #{certification_level_membership_last.certification_level.try(:name)}"
  end

  def can_be_deleted?
    sales.blank?
  end

  def has_local_tag?
    !tags.where( name: 'local' ).blank?
  end
end
