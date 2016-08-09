module ExtraEvents
  class ExtraEvent < ActiveRecord::Base
    has_paper_trail

    belongs_to :store
    belongs_to :tax_rate

    validates :type, :presence => true
    validates :name, :presence => true, :length => {:maximum => 255}
    validates :cost, :presence => true, :numericality => true
    validates :store, :existence => true
    validates :tax_rate, :existence => true

    attr_accessible :name, :cost, :tax_rate_id

    scope :with_costs, where("cost IS NOT NULL")
  end
end
