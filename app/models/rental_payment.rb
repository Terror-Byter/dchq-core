class RentalPayment < AllPayment
  belongs_to :rental

  validates :rental, presence: true

  before_validation :replace_uniq_id_to_amount
  after_save :update_rental_amounts!

  attr_accessible :rental, :rental_id

  private
  def replace_uniq_id_to_amount
    self.amount = amount.to_s.numeric? ? amount : 0 and return if !payment_method.try(:name).eql?("Gift Card") & (amount_for_search.to_s.numeric? || amount_for_search.blank?)
    if gift_card = rental.store.company.gift_cards.available.find_by_uniq_id(amount_for_search)
      if rental.change.abs > gift_card.available_balance
        self.amount = gift_card.available_balance
        gift_card.update_attributes available_balance: 0.0, status: "used"
      else
        self.amount = rental.change.abs
        gift_card.update_attributes available_balance: gift_card.available_balance - rental.change.abs, status: "partial"
      end
    else
      errors.add :base, I18n.t('models.rental_payment.cant_use_gift_card')
    end
  end

  def update_rental_amounts!
    rental.update_amounts!
  end
end
