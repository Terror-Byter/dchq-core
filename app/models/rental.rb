class Rental < ActiveRecord::Base
  has_paper_trail
  include AASM

  belongs_to :user, unscoped: true
  belongs_to :customer, unscoped: true
  belongs_to :store
  has_one :discount, as: :discountable

  COMPLETE_STATUSES = %w{complete overdue}

  with_options dependent: :destroy do |dd|
    dd.has_many :renteds
    dd.has_many :rental_payments
  end

  with_options presence: true do |v|
    v.validates :user
    v.validates :store
    v.validates :customer
    v.validates :pickup_date, timeliness: { type: :date }
    v.validates :return_date, timeliness: { type: :date, on_or_after: :pickup_date }
    v.validates :amount, numericality: { greater_than_or_equal_to: 0 }
    v.validates :grand_total, numericality: true
    v.validates :change, numericality: true
  end
  validates :note, length: { maximum: 65536 }

  accepts_nested_attributes_for :renteds, allow_destroy: true
  accepts_nested_attributes_for :discount, allow_destroy: true
  accepts_nested_attributes_for :rental_payments, reject_if: ->(p){ p["amount"].blank? }, allow_destroy: true

  attr_accessible :user_id, :user, :store_id, :store, :customer_id, :customer, :return_date, :pickup_date,
                  :status, :renteds_attributes, :note, :grand_total, :change, :rental_payments_attributes,
                  :completed_at, :discount_attributes

  after_save :update_amounts!
  after_update :update_status!
  after_save :send_xero

  scope :in_rent, ->{ where{ (status != 'complete') & (status != 'pay_pending') & (pickup_date <= Time.now) & (return_date >= Time.now) } }
  scope :for_invoice,  ->(working_time){ where(completed_at: working_time.open_at..working_time.close_at) }
  scope :completed, ->{ where(status: COMPLETE_STATUSES) }
  scope :completed_for_current_month, ->{ completed.where( created_at: Time.now.beginning_of_month..Time.now) }

  aasm column: 'status', skip_validation_on_save: true  do
    state :pay_pending, initial: true
    state :booked
    state :in_progress
    state :overdue
    state :complete

    event :to_booked, after: Proc.new { update_completed_at } do
      transitions from: [:pay_pending], to: :booked
    end

    event :to_in_progress do
      transitions from: :booked, to: :in_progress
    end

    event :to_overdue do
      transitions from: :in_progress, to: :overdue
    end

    event :to_complete, after: Proc.new { update_smart_line_item_price } do
      transitions from: [:in_progress, :overdue], to: :complete
    end
  end

  def update_amounts!
    if !@after_save_passed
      @after_save_passed = true
      self.reload
      sum = calc_grand_total
      sum += tax_rate_total unless store.tax_rate_inclusion?
      update_attributes! grand_total: sum, change: change_amount
    end
  end

  def sub_total
    calc_grand_total
  end

  def tax_rate_total
    renteds.sum(&:tax_rate_amount_line_item)
  end

  def calc_grand_total
    renteds.sum(&:line_item_price)
  end

  def calc_discount
    renteds.sum(&:line_item_discount)
  end

  def change_amount
    rental_payments.tendered.values.sum - grand_total
  end

  def layby?
    rental_payments.blank?
  end

  def days
    days = (return_date - pickup_date) / 1.day
    days < 1 ? 1 : days.round
  end

  def has_discount?
    discount && discount.value > 0
  end

  def invoice_line_amount_types
    store.tax_rate_inclusion? ? 'Inclusive' : 'Exclusive'
  end

  def invoice_attributes
    {
      type: 'ACCREC',
      contact: {
        # id: store.xero.contact_remote_id,
        name: customer.full_name
      },
      date: created_at,
      due_date: created_at,
      invoice_number: "RENTAL-#{created_at.strftime("%Y-%m-%d")}-#{id}",
      status: 'AUTHORISED',
      line_items: generate_line_items,
      line_amount_types: invoice_line_amount_types
    }
  end

  def generate_payments
    rental_payments.inject([]) do |payments, payment|
      payments << {
        invoice: {
          invoice_id: xero_invoice_id
        },
        account: {
          code: payment.payment_method.xero_code
        },
        date: payment.created_at.to_date,
        amount: payment.amount
      }
      payments
    end
  end

  def generate_line_items
    renteds.inject([]) do |array, rented|

      name = rented.rental_product.name
      unit_price = rented.unit_price
      tax_amount = rented.tax_rate_amount_line_item

      if customer.try(:zero_tax_rate?)
        name << ' (tax exempt)'
        unit_price -= tax_amount
        tax_amount = 0
      end

      array << {
        description: name,
        quantity: rented.quantity,
        unit_amount: unit_price || 0,
        account_code: store.xero.default_sale_account,
        tax_amount: tax_amount
      }

      array.last[:discount_rate] = ((1 - (rented.line_item/unit_price)) * 100)

      array
    end
  end

  def send_xero
    return unless store.xero.individual?
    return unless status == 'completed'

    Delayed::Job.enqueue(DelayedJob::Xero::SendSale.new(id))
  end

  private
  def update_status!
    reload
    if pay_pending?
      to_booked! if rental_payments.sum(:amount) >= grand_total && !grand_total.zero?
    end
  end

  def update_smart_line_item_price
    renteds.each { |r| r.update_column :smart_line_item_price, r.line_item_price }
  end

  def update_completed_at
    update_column :completed_at, Time.now
  end
end
