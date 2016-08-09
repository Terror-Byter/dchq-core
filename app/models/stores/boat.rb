module Stores
  class Boat < ActiveRecord::Base
    has_paper_trail

    belongs_to :store

    attr_accessible :color, :name

    has_many :events
    has_many :event_customer_participants, through: :events
    has_many :event_user_participants, through: :events

    with_options presence: true do |v|
      v.validates :name, length: { maximum: 255 }
      v.validates :store
      v.validates :color, format: { with: /^([a-f0-9]{6}|[a-f0-9]{3})$/i }
    end
  end
end
