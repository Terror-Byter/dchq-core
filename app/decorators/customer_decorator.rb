class CustomerDecorator < Draper::Decorator
  delegate_all
  decorates_association :credit_notes, scope: :ordered
  decorates_association :certification_level_memberships
  decorates_association :sales, scope: :newest_first
  decorates_association :event_customer_participants, scope: :not_refunded, scope: :ordered

  def address
    model.address.try(:full_address)
  end

  def primary_certificate
    primary = model.certification_level_memberships.primaries
    if primary.any?
      primary.first.try(:to_s)
    else
      model.certification_level_memberships.last.try(:to_s)
    end
  end

  def tags
    model.tag_list.map{ |tag| h.link_to(tag, "javascript:void(0);") }.join(', ')
  end

  def image
    h.image_tag(model.avatar.image(:large))
  end

  def last_dive_on
    l model.last_dive_on, format: :default if model. last_dive_on
  end

  def born_on
    l model.born_on, format: :default if model.born_on
  end

  def birthday
    l model.born_on, format: :birthday if model.born_on
  end

  def gender
    model.class.genders[model[:gender].to_sym] if model[:gender]
  end

  def discount
    "#{model.default_discount_level} %"
  end

  def fins
    "#{h.colon(model.fins)} #{h.customer_equipment_to_human(model.fins_own)}"
  end

  def bcd
    "#{h.colon(model.bcd)} #{h.customer_equipment_to_human(model.bcd_own)}"
  end

  def wetsuit
    "#{h.colon(model.wetsuit)} #{h.customer_equipment_to_human(model.wetsuit_own)}"
  end

  def mask
    h.customer_equipment_to_human model.mask_own
  end

  def regulator
    h.customer_equipment_to_human model.regulator_own
  end

  def no_certification_level_memberships?
    model.certification_level_memberships.empty?
  end

  def no_sales?
    model.sales.empty?
  end

  def no_event_customer_participants?
    model.event_customer_participants.empty?
  end

  def no_credit_notes?
    model.credit_notes.empty?
  end

  def no_notes?
    model.notes.empty?
  end

  def no_incidents?
    model.incidents.empty?
  end
end
