module Services
  class TypeOfService < ActiveRecord::Base
    include PgSearch

    pg_search_scope :search, against: [:name],
                           using: {
                             tsearch: {prefix: true, any_word: true },
                             trigram: { } },
                           ignoring: :accents
    has_paper_trail

    belongs_to :store
    belongs_to :tax_rate, with_deleted: true
    has_one :service_kit, :class_name => "Services::ServiceKit", :dependent => :destroy
    has_many :services

    scope :with_service_kit, :include => :service_kit, :conditions => "service_kits.id IS NOT NULL"

    attr_accessible :name, :labour, :labour_price, :tax_rate_id, :price_of_service_kit

    with_options :presence => true do |v|
      v.validates :name, :length => {:maximum => 255}
      v.validates :labour, :numericality => {:greater_than => 0}
      v.validates :labour_price, :numericality => {:greater_than => 0}
      v.validates :price_of_service_kit
      v.validates :store
    end

    def unit_price
      labour_price * labour
    end

    def sku_code
      ''
    end

    def quantity
      1
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

    def tax_rate_amount
      unit_price * tax_rate.try(:amount).to_f / 100
    end

    def name_for_sale
      "#{name} (#{ I18n.t('models.services.type_of_service.hours') })"
    end

    alias_attribute :label, :name_for_sale
  end
end
