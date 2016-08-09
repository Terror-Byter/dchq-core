class EventTrip < ActiveRecord::Base
  has_paper_trail

  belongs_to :store
  belongs_to :tax_rate
  belongs_to :commission_rate

  has_many :events

  validates :name, presence: true, length: { maximum: 255 }
  validates :cost, presence: true, numericality: true
  validates :store, existence: true
  validates :tax_rate, existence: true
  validates :commission_rate_money, presence: true, numericality: { greater_than: 0.0 }, if: ->(et){ et.commission_rate_id.blank? }
  validates :commission_rate, existence: true, if: ->(et){ et.commission_rate_money.blank? }
  validates :exclude_tariff_rates, inclusion: { in: [true, false] }
  validates :local_cost, numericality: { greater_than: 0 }, allow_blank: true

  attr_accessible  :name, :cost, :local_cost, :tax_rate_id, :commission_rate_id, :commission_rate_money,
                   :exclude_tariff_rates

  scope :with_cost, ->{ where{ cost.not_eq nil } }

  before_destroy :should_has_no_events

  def local_price_without_tax_rate
    local_cost
  end

  private
  def should_has_no_events
    errors.add :base, I18n.t('errors.has_events') unless events.empty?
    errors.blank?
  end
end
