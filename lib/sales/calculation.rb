module Sales::Calculation
  extend ActiveSupport::Concern

  included do
    has_one :prod_discount, as: :discountable, class_name: "Discount", dependent: :destroy

    accepts_nested_attributes_for :prod_discount, allow_destroy: true

    attr_accessible :prod_discount_attributes

    def line_item_price
      res = line_item
      res *= -1 if self.class.eql?(SaleProduct) && sale && sale.refunded?
      res
    end

    def unit_price
      if self.class.eql?(Rented)
        item_amount * rental.days
      else
        return price unless price.nil?
        BigDecimal.new(sale_productable.try(:unit_price).to_s)
      end
    end

    def line_item_price_with_tax_rate
      line_item_price if method.store.tax_rate_inclusion?
      line_item_price + tax_rate_amount
    end

    def line_item
      unit_price.abs * quantity - line_item_discount
    end

    def line_item_discount
      if defined?(sale_productable) && [EventCustomerParticipantOptions::Insurance, EventCustomerParticipantOptions::KitHire].include?(sale_productable.class)
        return unit_price if sale_productable.free?
      end

      return 0 unless discount

      line_sub_total = unit_price * quantity
      line_sub_total_with_discount = apply_discount(discount, line_sub_total)

      if line_sub_total_with_discount.zero?
        if discount && discount.value == 100 && discount.kind == 'percent'
          line_sub_total
        else
          0
        end
      else
        line_sub_total >= line_sub_total_with_discount ? line_sub_total - line_sub_total_with_discount : line_sub_total
      end
    end

    def apply_discount(discount, amount)
      temp_value = discount.value.blank? ? 0 : discount.value
      return amount if destroyed? || temp_value.zero?

      if discount.kind == 'percent'
        amount - amount * temp_value / 100.0
      else
        if method && method.discount
          amount - (amount / products.sum { |sp| sp.unit_price * sp.quantity } * temp_value).round(2)
        else
          amount - temp_value
        end
      end
    end

    def discount
      if [SaleProduct, Rented].include?(self.class)
        return method.discount if method && method.discount
      end
      return prod_discount if prod_discount
      nil
    end

    def apply_overlall_discount
      unit_price * quantity * method.discount.value / 100
    end

    private
    def method
      self.class.eql?(SaleProduct) ? sale : rental
    end

    def products
      method.respond_to?(:sale_products) ? method.sale_products : method.renteds
    end
  end
end
