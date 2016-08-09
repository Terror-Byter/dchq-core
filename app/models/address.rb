class Address < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail

  belongs_to :addressable, polymorphic: true, with_deleted: true

  with_options allow_blank: true do |o|
    o.with_options length: { maximum: 255 } do |v|
      v.validates :first
      v.validates :second
      v.validates :city
      v.validates :state
      v.validates :post_code
    end
    o.validates :country_code, inclusion: { in: CountrySelect::COUNTRIES.keys }
  end

  attr_accessible :first, :second, :city, :state, :country_code, :post_code

  before_validation :downcase_country_code

  def country
    self.country_code.blank? ? "" : CountrySelect::COUNTRIES[self.country_code]
  end

  def full_address(options = {})
    options = options.symbolize_keys.reverse_merge( separator: " ")
    address_attrs = [:first, :second, :city, :state, :post_code, :country]

    raise(I18n.t('models.address.invalid')) unless ((address_attrs | options[:only].to_a) - address_attrs).empty?

    (options[:only] || (address_attrs - options[:except].to_a)).map do |attr_name|
      self.send(attr_name)
    end.select(&:present?).join(options[:separator])
  end

  #TODO Duplicated
  def country_name
    self.country_code.blank? ? nil : CountrySelect::COUNTRIES[self.country_code]
  end

  def downcase_country_code
    self.country_code = self.country_code.try(:downcase)
  end
end
