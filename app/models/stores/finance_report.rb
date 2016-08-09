module Stores
  class FinanceReport < ActiveRecord::Base
    has_paper_trail

    belongs_to :store
    belongs_to :working_time

    has_many :finance_report_payments, dependent: :destroy, class_name: "Stores::FinanceReportPayment"

    accepts_nested_attributes_for :finance_report_payments

    with_options presence: true do |v|
      v.with_options numericality: true do |o|
        o.validates :total_payments
      end
      v.validates :store
      v.validates :working_time
    end
    validates :xero_url, url: { allow_blank: ->(u){ !u.sent } }
    #validate :check_finance_report_payments_sum

    attr_accessible :working_time, :total_payments, :discounts, :tax_total, :complete_payments,
      :finance_report_payments_attributes, :sent, :xero_url, :xero_invoice_id

    def invoice?
      type.eql?("Stores::Invoice")
    end
  end
end
