require "#{Rails.root}/lib/validations/email_not_fake.rb"

class User < ActiveRecord::Base
  include CurrentUserInfo
  include Common
  include PgSearch
  include AASM

  acts_as_paranoid
  acts_as_taggable

  pg_search_scope :search, against: [:given_name, :family_name],
                           using: {
                             tsearch: {prefix: true, any_word: true },
                             trigram: { } },
                           ignoring: :accents
  has_paper_trail

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
         :validatable

  belongs_to :company
  has_and_belongs_to_many :stores

  has_many :sales, foreign_key: "creator_id"
  has_many :notes, as: :notable
  has_many :services
  has_many :event_user_participants
  has_many :events, through: :event_user_participants
  has_many :tills
  has_many :rentals
  has_many :user_holidays
  has_one :avatar, as: :imageable, class_name: "Image"
  has_one :address, as: :addressable, autosave: true

  accepts_nested_attributes_for :avatar, allow_destroy: true
  accepts_nested_attributes_for :address, allow_destroy: true

  accepts_nested_attributes_for :user_holidays, allow_destroy: true, reject_if: ->(u) { u[:start_date].blank? || u[:end_date].blank? }

  with_options if: :step_1? do |o|
    o.validates :time_zone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }
    o.validates :role, presence: true, inclusion: { in: Role::ROLES }
  end
  validates :authentication_token, presence: true, uniqueness: true
  validates :address, presence: true, on: :update
  validates :avatar, presence: true, on: :update
  validates :email, email_not_fake: true
  validates :given_name, presence: true, length: { maximum: 255 }
  validates :family_name, presence: true, length: { maximum: 255 }
  validates :alternative_email, format: { with: Devise.email_regexp }, uniqueness: true, allow_blank: true
  validates :telephone, length: { maximum: 255 }, format: { with: /\A\+?[0-9\-\(\) ]*\Z/ }, allow_blank: true
  validates :sale_target, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  validate :should_be_minimum_one_manager, on: :update
  validate :validate_mailchimp_api_key, on: :update

  attr_accessor :from_edit_form

  attr_accessible :email, :password, :password_confirmation, :time_zone, :avatar_attributes, :address_attributes, :role, :instructor_number,
                  :store_ids, :remember_me, :from_edit_form, :passowrd_confirmation, :given_name, :family_name, :alternative_email,
                  :telephone, :emergency_contact_details, :available_days, :contracted_hours,
                  :mailchimp_api_key, :mailchimp_list_id_for_customer, :mailchimp_list_id_for_staff_member,
                  :mailchimp_list_id_for_business_contact, :locale, :sale_target, :sale_target_show_dashboard, :tag_list, :monday,
                  :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :user_holidays_attributes, :extra_days_off, :overtime

  serialize :available_days
  serialize :overtime, Array

  scope :managers, ->{ where(role: Role::MANAGER) }
  scope :staffs, ->{ where(role: Role::STAFF) }
  scope :not_in_holidays, -> do
    joins('LEFT JOIN user_holidays ON user_holidays.user_id = users.id')
    .where('? NOT BETWEEN user_holidays.start_date AND user_holidays.end_date OR (user_holidays.start_date IS NULL AND user_holidays.end_date IS NULL)', Date.today)
  end

  before_validation :ensure_authentication_token
  after_create :add_manager_to_all_store

  aasm column: 'current_step', skip_validation_on_save: true do
    state :step_1, initial: true
    state :step_2
    state :step_3
    state :finished

    event :to_step_2 do
      transitions from: :step_1, to: :step_2
    end

    event :to_step_3 do
      transitions from: :step_2, to: :step_3
    end

    event :to_finished do
      transitions from: :step_3, to: :finished
    end
  end

  class << self
    def field_names
      { email: "Email",
        time_zone: "Time Zone",
        role: "Role",
        current_step: "Current Step",
        given_name: "Given Name",
        family_name: "Family Name",
        alternative_email: "Alternative Email",
        telephone: "Phone",
        emergency_contact_details: "Emergency Contact Details",
        available_days: "Available Days",
        contacted_hours: "Contracted Hours",
        first: "Address First",
        second: "Address Second",
        city: "City",
        state: "State",
        country_code: "Country",
        post_code: "Post Code",
        instructor_number: "Instructor Number",
      }
    end
  end

  def self.serialized_attr_accessor(*args)
    args.each do |method_name|
      eval "
      def #{method_name}
        (self.available_days || {})[:#{method_name}]
      end
      def #{method_name}=(value)
        self.available_days ||= {}
        self.available_days[:#{method_name}] = value
      end
    "
    end
  end

  serialized_attr_accessor :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday

  def next_step
    aasm.states(permissible: true).map(&:name).first
  end

  def jump_to_next_step!
    send("to_#{next_step}!") if next_step
  end

  def manager?
    role.eql?(Role::MANAGER)
  end

  def purchase_amount
    sales.sum(:grand_total)
  end

  def add_manager_to_all_store
    return unless manager?
    company.stores.each do |store|
      store.users << self
      store.save
    end
  end

  def can_be_deleted?
    sales.blank? && events.blank?
  end

  def not_in_weekend
    available_days.blank? || available_days[Date.today.strftime('%A').downcase.to_sym] == 1.to_s
  end

  def on_holiday?
    user_holidays.select do |user_holiday|
      user_holiday.start_date <= Date.today && user_holiday.end_date >= Date.today
    end.any?
  end

  def available_on?(date)
    return false if (available_days.blank? || available_days[date.strftime('%A').downcase.to_sym] != '1')

    user_holidays.select do |user_holiday|
      user_holiday.start_date <= date && user_holiday.end_date >= date
    end.blank?
  end

  def can_be_add_to_event event
    true
  end

  def remove_empty_sales!
    sales.empty.delay.destroy_all
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_token 'authentication_token'
    end
  end

  def full_name
    [self.given_name, self.family_name].select(&:present?).join(' ')
  end

  def available_days_for_export
    available_days.map{ |u| u.last == '1' ? 'true' : false }.join("|")
  end

  private
  def should_be_minimum_one_manager
    errors.add(:base, I18n.t('models.user.manager_error')) if !manager? && company && company.users.managers.count < 2
  end

  def validate_mailchimp_api_key
    if mailchimp_api_key.present?
      gb = Gibbon::API.new self.mailchimp_api_key
      begin
        gb.users
      rescue
        errors.add :mailchimp_api_key, "Invalid Mailchimp API Key"
        return false
      end
    end
  end
end
