class SaleCustomerDecorator < Draper::Decorator
  delegate_all

  def full_name
    model.customer.full_name
  end

  def full_address
    model.customer.address.full_address
  end

  def telephone
    model.customer.telephone
  end

  def phone
    model.customer.mobile_phone
  end

  def email
    model.customer.email
  end

  def tax_id
    model.customer.tax_id
  end
end
