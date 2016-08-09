module EventCustomerParticipantOptions
  class Insurance < EventCustomerParticipantOption
    belongs_to :insurance, :class_name => "ExtraEvents::Insurance"
    has_one :sale_product, conditions: { sale_productable_type: 'EventCustomerParticipantOptions::Insurance' }, dependent: :destroy, foreign_key: :sale_productable_id

    attr_accessible :insurance_id, :free, :event_customer_participant_id,
                    :created_at, :updated_at

    validates :insurance_id, :existence => true, :if => :free?

    def class_type
      self.class.name
    end
  end
end
