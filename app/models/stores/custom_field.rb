module Stores
  class CustomField < ActiveRecord::Base
    has_paper_trail

    belongs_to :customer, with_deleted: true

    attr_accessible :name, :value

    validates :name, presence: true, length: { maximum: 255 }
    validates :value, length: { maximum: 255 }
  end
end
