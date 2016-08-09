class GiftCardDecorator < Draper::Decorator
  delegate_all

  def sales
    model.sales.map{|i| h.link_to i.id, i}.join(", ").html_safe
  end

  def solded_at
    l model.solded_at, format: :default
  end

  def expiry_date
    l model.solded_at + model.gift_card_type.valid_for.months, format: :default
  end

  def status
    GiftCard::STATUSES[model.status]
  end
end
