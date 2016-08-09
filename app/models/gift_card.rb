class GiftCard < ActiveRecord::Base
  STATUSES = {
              "used" => I18n.locale.eql?(:en) ? "Used" : I18n.locale.eql?(:fr) ? "" : "",
              "un-used" => I18n.locale.eql?(:en) ? "Un-used" : I18n.locale.eql?(:fr) ? "" : "",
              "partial" => I18n.locale.eql?(:en) ? "Partial" : I18n.locale.eql?(:fr) ? "" : "",
              "not_sold" => I18n.locale.eql?(:en) ? "Not Sold" : I18n.locale.eql?(:fr) ? "" : ""
             }
  has_paper_trail

  belongs_to :gift_card_type
  has_many :sale_products, as: :sale_productable, dependent: :destroy
  has_many :sales, through: :sale_products, uniq: true

  validates :gift_card_type, presence: true
  validates :available_balance, presence: true, numericality: { greater_than_or_equal: 0.0 }
  validates :uniq_id, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES.keys }

  before_validation :generate_uniq_id, :add_balance, :add_status
  attr_accessible :uniq_id, :status, :solded_at

  scope :solded_on_this_month, lambda{|gift_card_type| where(solded_at: Time.now.at_beginning_of_month..Time.now, gift_card_type_id: gift_card_type.id)}
  scope :solded_on_this_week, where(solded_at: Time.now.at_beginning_of_week..Time.now)
  scope :available, where{((status.eq "un-used") | (status.eq "partial"))}
  scope :enable_to_show, where{(status.not_eq 'not_sold')}

  def can_destroy?
    status.eql?("not_sold")
  end

  def logo
    nil
  end

  def sku_code
    "GIFTCARD_#{value}"
  end

  def unit_price
    value
  end

  def value
    gift_card_type.value
  end

  def number_in_stock
    0
  end

  def name
    gift_card_type.name
  end

  def class_type
    self.class.name
  end

  def tax_rate_amount
    0
  end

  private
  def generate_uniq_id
    self.uniq_id = Digest::SHA2.hexdigest(rand.to_s)[0,15] if new_record?
  end

  def add_balance
    self.available_balance = gift_card_type.value if new_record?
  end

  def add_status
    self.status = "not_sold" if new_record?
  end
end
