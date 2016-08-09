module Stores
  class EventTariff < ActiveRecord::Base
    has_paper_trail

    belongs_to :user
    attr_accessible :name, :min, :max, :percentage

    with_options :presence => true do |v|
      v.validates :name, :length => {:maximum => 255}
      v.validates :min, :numericality => {:greater_than => 0}
      v.validates :max, :numericality => {:greater_than => :min}
      v.validates :percentage, :numericality => {:greater_than => 0}
    end
  end
end
