module Services
  class ServiceItem < ActiveRecord::Base
    has_paper_trail

    belongs_to :service
    belongs_to :product

    validates :product, presence: true

    attr_accessible :product_id, :product

    after_create :decrease_product
    after_destroy :increase_product
    private

    def decrease_product
      product.update_attributes number_in_stock: product.number_in_stock - 1
    end

    def increase_product
      product.update_attributes number_in_stock: product.number_in_stock + 1
    end
  end
end
