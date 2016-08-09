class GiftCardType < ActiveRecord::Base
  VALID_INTERVAL_IN_MONTH = [3, 6, 9, 12]

  include PgSearch

  pg_search_scope :search, against: [:name],
                           using: {
                             tsearch: {prefix: true, any_word: true },
                             trigram: { } },
                           ignoring: :accents
  has_paper_trail

  attr_accessible :value, :can_sold, :valid_for

  belongs_to :company
  has_many :gift_cards, dependent: :destroy

  validates :company_id, presence: true
  validates :valid_for,  presence: true, inclusion: { in: VALID_INTERVAL_IN_MONTH }, uniqueness: { scope: [:value, :company_id] }
  validates :value,      presence: true, numericality: { greater_than: 0.0 }, uniqueness: { scope: [:valid_for, :company_id] }
  validates :can_sold,   inclusion: { in: [true, false] }
  validates :uniq_id,    presence: true, uniqueness: true, on: :update
  validates :name,       presence: true

  before_create :generate_unqi_id
  before_validation :add_name

  scope :enable_sold, ->{ where(can_sold: true) }

  def label
    name
  end

  def class_type
    self.class.name
  end

  def create_gift_card
    gift_card = self.gift_cards.build
    gift_card.save
    gift_card
  end

  private
  def add_name
    self.name = "#{sprintf("%.2f", self.value)} Gift Card (valid for: #{self.valid_for} months)"
  end

  def generate_unqi_id
    self.uniq_id = Digest::SHA2.hexdigest(rand.to_s)[0,15]
  end
end
