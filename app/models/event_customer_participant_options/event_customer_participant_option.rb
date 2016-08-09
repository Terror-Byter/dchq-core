module EventCustomerParticipantOptions
  class EventCustomerParticipantOption < ActiveRecord::Base
    has_paper_trail
    include CurrentStoreInfo

    belongs_to :event_customer_participant

    has_one :discount, as: :discountable, class_name: "Discount", dependent: :destroy

    accepts_nested_attributes_for :discount, allow_destroy: true

    attr_accessible :event_customer_participant_id, :discount_attributes

    def local?
      false
    end

    def base_event?
      self.is_a?(EventCustomerParticipant)
    end

    def dynamic_quantity
      1
    end

    def unit_price
      return 0 unless method
      method.cost
    end

    def line_item_discount
      line_sub_total = unit_price
      line_sub_total *= quantity if discounts
      line_sub_total_with_discount = discounts.try(:apply, line_sub_total).to_f

      if line_sub_total_with_discount.zero?
        if discounts && discounts.value >= 100 && discounts.kind == 'percent'
          line_sub_total
        else
          0
        end
      else
        line_sub_total > line_sub_total_with_discount ? line_sub_total - line_sub_total_with_discount : line_sub_total
      end
    end

    def apply_overlall_discount
      unit_price * quantity * event_customer_participant.sale.discount.value.to_f / 100
    end

    def quantity
      self.respond_to?(:dynamic_quantity) ? self.dynamic_quantity.to_i : 1
    end

    def tax_rate_amount
      return 0 if !method || ( event_customer_participant && event_customer_participant.customer && event_customer_participant.customer.try(:zero_tax_rate?) ) || dynamic_quantity.zero?

      tax = method.tax_rate.amount.to_f / 100
      if store.try(:tax_rate_inclusion?)
        return line_item_price / (tax + 1) * tax
      else
        return line_item_price * tax
      end
    end

    def line_item_price
      return 0 if self.try(:free?)
      res = line_item
      res *= -1 if sale_refunded?
      res
    end

    def line_item
      return 0 if self.try(:free?)
      unit_price * dynamic_quantity - line_item_discount
    end

    def name
      method.try(:name)
    end

    def nested_attribute_name
      res = self.class.name.underscore.gsub("options/", '')
      res = res.tableize unless kit_hire_or_insurance?
      res
    end

    def kit_hire_or_insurance?
      [:insurance, :kit_hire].include?(saleable_name)
    end

    def saleable_name
      return :event if self.base_event?
      self.class.name.gsub(/EventCustomerParticipantOptions::/, '').underscore.to_sym
    end

    def attrs_for_clone
      res = { event_customer_participant_id: self.event_customer_participant_id, "#{self.saleable_name}_id".to_sym => saleable.try(:id)}
      res.update({ free: self.free }) if self.kit_hire_or_insurance?
      res
    end

    def clone_discount original
      self.send("build_discount", original.attrs_for_clone) if original
    end

    def logo
      nil
    end

    def sku_code
      nil
    end

    def number_in_stock
      1
    end

    private
    def saleable
      self.send(saleable_name)
    end

    def method
      send(self.class.name.demodulize.underscore)
    end

    def sale_refunded?
      sale = self.base_event? ? self.sale : self.event_customer_participant.try(:sale)
      return false unless sale
      sale.refunded?
    end

    def price_unit_method
      saleable.respond_to?(:cost) ? :cost : :price
    end

    def discounts
      return discount if discount && !discount.new_record?
      event_customer_participant.sale.discount if event_customer_participant.try(:sale) && event_customer_participant.sale.discount
    end

    def store
      return current_store_info if current_store_info
      return event_customer_participant.event.store if event_customer_participant
      nil
    end
  end
end
