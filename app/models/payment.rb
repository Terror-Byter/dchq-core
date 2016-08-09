class Payment < AllPayment
  belongs_to :sale

  validates :sale, presence: true

  before_save :update_refund_amount
  after_create :update_sale_status!
  before_validation :replace_uniq_id_to_amount
  after_save :update_sale_amounts!, :calculate_credit_note
  after_destroy :update_sale_amounts!, :update_sale_status!, :recalculate_credit_note

  scope :refunds, ->{ includes(:sale).where( sale: { status: 'complete_refund' } ) }
  scope :for_complete_sales, ->{ includes(:sale).where( sale: { status: ['complete', 'complete_refund'] } ) }

  attr_accessible :sale_id, :sale, :created_at

  def replace_uniq_id_to_amount
    self.amount = amount.to_s.numeric? ? amount : 0 and return if !payment_method.try(:name).eql?("Gift Card") & (amount_for_search.to_s.numeric? || amount_for_search.blank?)
    if gift_card = sale.store.company.gift_cards.available.find_by_uniq_id(amount_for_search)
      if sale.change.abs > gift_card.available_balance
        self.amount = gift_card.available_balance
        gift_card.update_attributes available_balance: 0.0, status: "used"
      else
        self.amount = self.sale.change.abs
        gift_card.update_attributes available_balance: gift_card.available_balance - self.sale.change.abs, status: "partial"
      end
    else
      errors.add(:base, I18n.t('models.payment.cant_use_gift_card'))
    end
  end

  private
  def update_refund_amount
    self.amount = -1 * amount.abs if sale.refund?
  end

  def update_sale_amounts!
    sale.update_amounts!
  end

  def update_sale_status!
    sale.update_status!
  end

  def calculate_credit_note
    return unless payment_method.name.eql?("Credit Note")
    #add credit note
    customer = Customer.find(customer_id)
    if sale.refund?
      CreditNote.create(sale_id: sale.id,
                        customer_id: customer.id,
                        initial_value: amount.abs,
                        remaining_value: amount.abs)
      customer.update_attribute :credit_note, customer.credit_note.abs + amount.abs
    #minus credit note
    else
      CreditNote.create(sale_id: sale.id,
                        customer_id: customer.id,
                        initial_value: customer.credit_note.abs,
                        remaining_value: customer.credit_note.abs - amount.abs
                       )
      customer.update_attribute :credit_note, customer.credit_note.abs - amount.abs
    end
  end

  def recalculate_credit_note
    return unless payment_method.name.eql?("Credit Note")
    #add credit note
    customer = Customer.find(customer_id)
    CreditNote.create(sale_id: sale.id,
                        customer_id: customer.id,
                        initial_value: amount.abs,
                        remaining_value: amount.abs)
      customer.update_attribute :credit_note, customer.credit_note.abs + amount.abs
  end
end
