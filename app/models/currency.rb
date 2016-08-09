class Currency < ActiveRecord::Base
  has_paper_trail

  has_many :stores

  validates :name, presence: true
  validates :code, presence: true
  validates :unit, presence: true
  validates :precision, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 128 }

  with_options allow_blank: true do |v|
    v.validates :name,      length: { maximum: 255 }
    v.validates :unit,      length: { maximum: 255 }
    v.validates :separator, length: { maximum: 255 }
    v.validates :delimiter, length: { maximum: 255 }
    v.validates :code, format: { with: /\A[A-Z]{3}\Z/ }, uniqueness: { case_insensitive: false }
  end

  attr_accessible :name, :unit, :code, :separator, :delimiter, :format, :precision

  before_validation :normalize_attributes!
  before_destroy :must_not_destroy_when_dependents_exist
  after_save :update_discounts

  scope :order_by_name, ->(direction){ { order: "#{quoted_table_name}.`name` #{direction}" } }

  def self.discount_options
    all.map{ |c| [c.code, c.unit.html_safe]}.inject({}) {|ha, (k, v)| ha[k] = v; ha}
  end

  def format_options
    attributes.symbolize_keys.slice(:unit, :separator, :delimiter, :format, :precision)
  end

  protected
  def update_discounts
    Discount.update_all({ kind: self.code}, { kind: self.code_was}) if self.code_changed?
  end

  def normalize_attributes!
    self.name = name.to_s.mb_chars.strip
    self.unit = unit.to_s.mb_chars.strip
    self.code = code.to_s.mb_chars.upcase.strip
    true
  end

  def must_not_destroy_when_dependents_exist
    unless deletable?
      errors.add_to_base(:destroy_when_dependents_exist)
      false
    else
      true
    end
  end
end
