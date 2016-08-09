class SaleCustomer < ActiveRecord::Base
  has_paper_trail
  attr_accessible :customer

  belongs_to :sale
  belongs_to :customer, unscoped: true
  has_one :company, through: :sale

  with_options existence: true do |e|
    e.validates :sale
    e.validates :customer
  end

  validates :sale_id, uniqueness: { scope: :customer_id }

  after_create :remove_walk_in!
  after_destroy :add_walk_in!

  attr_accessible :customer_id

  def check_default_discount_level
    sale_discount = self.sale.discount

    return false unless sale.can_contain_discount?
    return false unless self.customer.apply_default_discount_level?(sale_discount.try(:value))

    unless sale_discount
      self.sale.create_discount(value: self.customer.default_discount_level)
    else
      return false unless sale_discount.percent?
      sale_discount.update_attributes(value: self.customer.default_discount_level)
    end

    true
  end

  def has_unpaid_events?
    !self.customer.event_customer_participants.unpaid.empty?
  end

  def alone_walk_in?
    self.sale.sale_customers.count.eql?(1) && self.customer.walk_in?
  end

  private
  def add_walk_in!
    return unless sale
    if !caller.join("!").include?("active_admin") and !caller.join("!").include?("destroy_all_childrens")
      self.sale.sale_customers.create(customer: self.company.default_customer) if self.sale.sale_customers.count.zero?
    end
  end

  def remove_walk_in!
    walk_in = self.company.default_customer
    walk_in_sale_customer = self.sale.sale_customers.find_by_customer_id(walk_in)

    walk_in_sale_customer.destroy if walk_in_sale_customer && !self.customer_id.eql?(walk_in.id)
  end
end
