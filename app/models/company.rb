class Company < ActiveRecord::Base
  include Common
  has_paper_trail

  belongs_to :primary_contact, class_name: "User"
  belongs_to :referrer, class_name: 'Company', primary_key: 'referral_code', foreign_key: 'invite_code'

  with_options dependent: :destroy do |o|
    o.has_many :stores
    o.has_many :users
    o.has_many :staff_members, class_name: "User"
    o.has_many :customers
    o.has_many :suppliers

    o.has_one :owner, class_name: "User", order: :created_at
    o.has_one :default_store, class_name: "Store", order: :created_at
    o.has_one :address, as: :addressable
    o.has_one :logo, as: :imageable, class_name: "Image"

    o.has_one :payment_credential
    o.has_many :gift_card_types
    o.has_many :sales, through: :stores
    o.has_many :other_events, through: :stores
    o.has_many :course_events, through: :stores
    o.has_many :services, through: :stores

    o.has_many :smart_lists
  end

  has_many :gift_cards, through: :gift_card_types
  has_many :business_contacts, through: :suppliers
  has_many :invited, class_name: 'Company', primary_key: 'referral_code', foreign_key: 'invite_code'

  accepts_nested_attributes_for :default_store, allow_destroy: true
  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :logo, allow_destroy: true
  accepts_nested_attributes_for :stores, allow_destroy: true
  accepts_nested_attributes_for :payment_credential

  validates :enabled, inclusion: { in: [true, false] }
  validates :api_key, presence: true, uniqueness: true
  validates :website_url, url: { allow_blank: true }
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :telephone, presence: true, length: { maximum: 255 }, format: { with: /\A\+?[0-9\-\(\) ]*\Z/ }
  validates :email, presence: true, email_format: true
  validates :referral_code, presence: true, length: { maximum: 255 }
  validates :tax_id, length: { maximum: 255 }

  with_options if: ->(dc){ dc.payment_subscription.present? } do |o|
    o.validates :payment_method, presence: true
  end

  validate :verify_email_for_fake

  scope :enabled, ->{ where(enabled: true) }
  scope :disabled, ->{ where(enabled: false) }
  scope :all_centres

  attr_protected :api_key
  attr_accessible :users_attributes, :name, :telephone, :email, :website_url, :enabled,
                  :api_key, :address_attributes,
                  :logo_attributes, :payment_method,
                  :stores_attributes, :primary_contact_id, :invite_code,
                  :currency_for_store, :tax_id

  attr_accessor :payment_subscription, :currency_for_store

  before_validation :check_http, on: :update
  before_validation :generate_api_key, :generate_referral_code, on: :create
  after_create :add_default_store,
               :add_default_customer,
               :send_welcome_email,
               :add_payment_credential,
               :add_logo,
               :set_outbound_email,
               :setup_mailgun_route

  after_destroy :unsubscribe_dive_centre

  def events_count
    other_events.count + course_events.parent.count
  end

  def default_customer
    customers.find_by_email(Figaro.env.walk_in_email) || add_default_customer
  end

  def search_people query
   result = customers.search(query).map{ |u| { name: u.full_name, type: u.class.name.downcase, id: u.id } }
   result += users.search(query).map{ |u| { name: u.full_name, type: u.class.name.downcase, id: u.id } }
   result += suppliers.search(query).map{ |u| { name: u.name, type: u.class.name.downcase, id: u.id } }
  end

  def set_paypal?
    !payment_credential.paypal_login.blank? && !payment_credential.paypal_password.blank? && !payment_credential.paypal_signature.blank?
  end

  def set_stripe?
    !payment_credential.stripe_secret_key.blank? && !payment_credential.stripe_publishable_key.blank?
  end

  def set_epay?
    !payment_credential.epay_merchant_number.blank? && !payment_credential.epay_password.blank? && !payment_credential.epay_currency.blank?
  end

  def extra_stores
    stores.extra
  end

  def count_extra_stores
    extra_stores.count
  end

  def available_for_event_users event
    users.includes(:user_holidays).select(&:not_in_weekend).select { |u| u.can_be_add_to_event(event) }.map do |u|
      u.family_name += ' (on holiday)' if u.on_holiday?
      u
    end
  end

  private
  def check_http
     return if website_url.blank?
     self.website_url = "http://#{self.website_url}" if self.website_url.match(/(http:\/\/|https:\/\/)/).blank? && !self.website_url.blank?
  end

  def generate_api_key
    self.api_key = generate_token 'api_key'
  end

  def generate_referral_code
    self.referral_code = rand(10**8).to_s[1..6]
  end

  def add_default_store
    self.stores.create(name: name, location: 'location', currency_id: currency_for_store, main: true) if stores.empty?
  end

  def add_default_customer
    res = self.customers.create( given_name: "Walk", family_name: "In", email: Figaro.env.walk_in_email,
                                 telephone: "000-000-0000", mobile_phone: "000-000-0000",
                                 customer_experience_level_id: CustomerExperienceLevel.first )
    res.build_address unless res.address
    res.build_avatar unless res.avatar
    res.save!
    res
  end

  def send_welcome_email
    self.reload
    CompanyMailer.delay.welcome(self)
  end

  def verify_email_for_fake
    result = EmailVeracity::Address.new(self.email)
    errors.add(:email, I18n.t('models.company.email_is_fake')) unless result.valid?
  end

  def add_payment_credential
    self.create_payment_credential
  end

  def referral_code_should_be_uniq
    errors.add(:referral_code, I18n.t('models.company.should_be_uniq')) unless self.class.where(referral_code: self.referral_code).empty?
  end

  def invite_code_should_exist
    return if invite_code.blank?
    errors.add(:invite_code, I18n.t('models.company.should_be_present')) if self.class.where(referral_code: self.invite_code).empty?
  end

  def add_logo
    create_logo unless logo
  end

  def outbound_email_token
    [
      name.to_s.downcase.gsub(/[^[a-zA-Z0-9_+-]]+/, ''),
      id,
      SecureRandom.hex(16)
    ].join('.')
  end

  def set_outbound_email
    return if outbound_email
    update_attribute(:outbound_email, "#{outbound_email_token}@#{Figaro.env.mailgun_domain}")
  end

  def setup_mailgun_route
    @counter ||= 0
    begin
      return if @counter > 2
      url = URI.parse('https://api.mailgun.net/v3/routes')
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth('api', Figaro.env.mailgun_api_key)
      req.set_form_data(
        priority: 0,
        description: name,
        expression: "match_recipient('#{outbound_email}')",
        action: "forward('#{email}')"
      )
      sock = Net::HTTP.new(url.host, url.port)
      sock.use_ssl = true
      res = sock.start {|http| http.request(req) }

      res = JSON.parse(res.body)

      update_attribute(:mailgun_id, res['route']['id'])
    rescue
      @counter += 1
      setup_mailgun_route
    end
  end
end
