module EventCustomerParticipantOptions
  class Transport < EventCustomerParticipantOption

    belongs_to :transport, class_name: "ExtraEvents::Transport"
    has_one :sale_product, conditions: { sale_productable_type: 'EventCustomerParticipantOptions::Transport' }, dependent: :destroy, foreign_key: :sale_productable_id

    with_options unless: ->(u){ u.transport_id.blank? } do |v|
      v.validates :information, length: { maximum: 255 }, allow_blank: true
      v.validates :time, timeliness: { type: :time }
      v.validates :start_date, timeliness: { type: :date }
      v.validates :transport_id, presence: true
    end

    scope :order_by_day, order: "number_of_days ASC"
    scope :active, where("transport_id IS NOT NULL")
    scope :order_by_time, order: "start_date ASC, time ASC"
    scope :today, where(start_date: Date.today)

    attr_accessible :transport_id, :time, :information, :start_date

    def dynamic_quantity
      unless new_record?
        return 0 if event_customer_participant.blank? || event_customer_participant.grouped_transports.blank?
        event_customer_participant.grouped_transports[transport_id].try(:size).to_i
      else
        1
      end
    end

    def class_type
      self.class.name
    end

    def attrs_for_clone
      super.merge({ time: time, information: information, start_date: start_date, transport_id: transport_id })
    end

    def only_time
      time.blank? ? '' : time.to_s(:time)
    end
  end
end
