class ScubaTribeForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [:first_name, :last_name, :company_name,
    :email_address, :telephone_number, :current_store]

  ERRORS = {
    152 => 'Address appears invalid',
    153 => 'An account with this email address already exists'
  }

  attr_accessor *ATTRIBUTES

  with_options length: { maximum: 255, minimum: 3 } do |l|
    l.with_options presence: true do |p|
      p.validates :first_name
      p.validates :last_name
      p.validates :company_name
      p.validates :email_address
      p.validates :telephone_number
    end
  end

  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end

  def persisted?
    false
  end

  def save
    return false unless valid?

    scubatribe_service = ScubaTribe.new
    account = scubatribe_service.signup(
      first_name: first_name,
      last_name: last_name,
      company_name: company_name,
      email_address: email_address,
      telephone_number: telephone_number
    )

    if account['status'] == 'error'
      account['error'].each do |error|
        errors[error['field'].to_sym] << (ERRORS[error['code']].presence || error['msg'])
      end
      return false
    end

    scubatribe = Stores::ScubaTribe.new
    scubatribe.api_key = account['api_key']
    scubatribe.store = current_store
    scubatribe.user_id = account['user_id']
    scubatribe.save
  end
end
