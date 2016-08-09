module Stores
  class FinanceReportPayment < ActiveRecord::Base
    has_paper_trail

    belongs_to :finance_report
    belongs_to :payment

    validates :finance_report, presence: true, on: :update
    with_options if: ->(u){ u.payment.blank? } do |v|
      v.validates :amount, presence: true, numericality: true
      v.validates :custom_amount, presence: true, numericality: true
      v.validates :name, presence: true, length: { maximum: 255 }
    end
    validates :payment, presence: true, unless: ->(u){ u.payment.blank? }

    attr_accessible  :name, :amount, :custom_amount, :payment

    scope :complete, where{ payment_id.eq nil }
  end
end
