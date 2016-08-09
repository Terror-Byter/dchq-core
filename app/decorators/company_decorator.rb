class CompanyDecorator < Draper::Decorator
  delegate_all

  def primary_contact_ids
    users.managers.collect{|u| [u.full_name, u.id]}
  end

  def referrer_name
    return nil unless referrer
    referrer.name
  end

  def invited_stores_names
    invited.pluck(:name)
  end

  def image_large
    h.image_tag model.logo.image.url(:large), alt: 'Logo'
  end

  def image_thumb
    h.image_tag model.logo.image.url(:thumb), alt: 'Logo', style: 'height: 40px'
  end

  def has_image?
    logo.image.exists?
  end

  def count_gift_cards_solded_this_month(card_type)
    gift_cards_solded_this_month(card_type).count
  end

  def gift_cards_solded_this_month(card_type)
    gift_cards.solded_on_this_month(card_type)
  end

  def has_cards_sold_this_month?(card_type)
    !gift_cards_solded_this_month(card_type).blank?
  end

  def gift_cards_solded_this_month_at(card_type)
    gift_cards_solded_this_month(card_type).last.solded_at
  end

  def users_names_and_ids
    users.map{|u| [u.full_name, u.id]}
  end

  def customers_names_and_ids
    customers.map{|u| [u.full_name, u.id]}
  end

  def customers_count
    customers.count
  end

  def messages
  end

end
