module SaleMixin
  def name
    return "#{saleable.try(:name)} (#{ customer ? customer.try(:full_name) : " #{ self.dynamic_quantity } people " })" if self.base_event?

    res = "#{self.saleable_name.to_s.classify}: #{saleable.try(:name)}"
    res << " (FREE)" if self.free?
    res
  end

  def free?
    self.respond_to?(:free) && self.free
  end

  def nested_attribute_name
    res = self.class.name.underscore.gsub("options/", '')
    res = res.tableize unless kit_hire_or_insurance?
    res
  end

  #TODO
  def discount_method
    return :event_customer_participant_discount if self.base_event?
    :discount
  end

  def discount
    self.send(self.discount_method)
  end

  def quantity
    self.respond_to?(:dynamic_quantity) ? self.dynamic_quantity.to_i : 1
  end

  def base_event?
    self.is_a?(EventCustomerParticipant)
  end

  def clone_discount original
    self.send("build_#{self.discount_method}", original.attrs_for_clone) if original
  end

  def attrs_for_clone
    res = { event_customer_participant_id: self.event_customer_participant_id, "#{self.saleable_name}_id".to_sym => saleable.try(:id)}
    res.update({ free: self.free }) if self.kit_hire_or_insurance?
    res
  end

  def saleable_name
    return :event if self.base_event?
    self.class.name.gsub(/EventCustomerParticipantOptions::/, '').underscore.to_sym
  end

  def kit_hire_or_insurance?
    [:insurance, :kit_hire].include?(saleable_name)
  end

  private
  def saleable
    self.send(saleable_name)
  end

  def tax_rate_withdrawal_coef
    tax_rate = saleable.respond_to?(:tax_rate) && saleable.tax_rate
    return 1 unless tax_rate

    tax_rate.withdrawal_coef
  end

  def price_unit_method
    saleable.respond_to?(:cost) ? :cost : :price
  end

  def sale_refunded?
    sale = self.base_event? ? self.sale : self.event_customer_participant.try(:sale)
    return false unless sale
    sale.refunded?
  end
end
