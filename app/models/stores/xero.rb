module Stores
  class Xero < ActiveRecord::Base
    has_paper_trail

    belongs_to :store

    validates :store, presence: true
    validates :xero_consumer_key, length: { maximum: 255 }, allow_blank: ->(u){ u.xero_consumer_secret.blank? }
    validates :xero_consumer_secret, length: { maximum: 255 }, allow_blank: ->(u){ u.xero_consumer_key.blank? }
    validates :valid_tax_rate, inclusion: { in: [true, false] }

    attr_accessible :xero_session_handle, :xero_consumer_key, :xero_consumer_secret,
      :expires_at, :valid_tax_rate, :default_sale_account, :cost_of_goods_sold,
      :rounding_errors_account, :till_payment_discrepancies, :integration_type, :integration_type_individual

    attr_accessor :integration_type_individual

    def individual?
      integration_type == 'individual'
    end

    def batch?
      [integration_type_individual, integration_type].include?('batch')
    end

    def end_of_day?
      integration_type == 'end_of_day'
    end
  end
end
