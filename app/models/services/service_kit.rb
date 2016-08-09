module Services
  class ServiceKit < ActiveRecord::Base
    has_paper_trail

    belongs_to :store
    belongs_to :type_of_service
    belongs_to :tax_rate

    attr_accessible :name, :stock_level, :type_of_service_id, :tax_rate_id, :supply_price, :retail_price

    with_options :presence => true do |v|
      v.validates :name, :length => {:maximum => 255}
      v.validates :stock_level, :numericality => {:greater_than_or_equal_to => 0}
      v.validates :supply_price, :numericality => {:greater_than_or_equal_to => 0.0}
      v.validates :retail_price, :numericality => {:greater_than_or_equal_to => 0.0}
      v.validates :type_of_service_id, :uniqueness => {:scope => [:store_id]}
      v.validates :store
      v.validates :tax_rate
    end

    def sku_code
      ''
    end

    def quantity
      1
    end

    def name_for_sale
      name
    end

    def unit_price
      return 0 if type_of_service.try(:price_of_service_kit) == "included"
      retail_price
    end

    def tax_rate_amount
      unit_price * tax_rate.amount / 100
    end

    def line_item_price sale = nil
      return line_item if sale.nil?
      res = self.line_item(sale)
      res *= -1 if sale.refunded?
      res
    end

    def line_item sale = nil
      return unit_price * quantity if sale.blank? || sale.store.tax_rate_inclusion?
      (unit_price + tax_rate_amount) * quantity
    end
  end
end
