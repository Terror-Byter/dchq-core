class Discount < ActiveRecord::Base
  has_paper_trail

  belongs_to :discountable, :polymorphic => true

  with_options unless: ->(u){ u.value.blank? } do |v|
    v.validates :value, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, if: :percent?
    v.validates :value, numericality: { greater_than_or_equal_to: 0 }, unless: :percent?
  end
  validates :kind, presence: true, inclusion: { in: ->(p){ self.kinds_with_percent.keys } }

  attr_accessible :kind, :value, :discountable_type, :discountable_id

  after_save :destroy_if_value_is_nil

  class << self
    def kinds_with_percent
      {"percent" => "%"}.merge(Currency.discount_options)
    end
  end

  def percent?
    kind.eql?('percent')
  end

  def apply(amount)
    temp_value = value.blank? ? 0 : value
    return amount if destroyed?

    if percent?
      amount - amount * temp_value / 100.0
    else
      amount >= temp_value ? amount - temp_value : amount
    end
  end

  def attrs_for_clone
    attributes.symbolize_keys.slice(:kind, :value)
  end

  private
  def destroy_if_value_is_nil
    destroy if value.blank? || value.zero?
  end
end
