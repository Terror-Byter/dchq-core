module Services
  class Kit < ActiveRecord::Base
    belongs_to :service
    belongs_to :type_of_service

    attr_accessible :kit, :serial_number, :type_of_service_id

    with_options presence: true do |v|
      v.validates :type_of_service
      v.validates :kit, length: { maximum: 255 }
      v.validates :serial_number, length: { maximum: 255 }
    end
  end
end
