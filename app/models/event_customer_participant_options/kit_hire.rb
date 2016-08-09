module EventCustomerParticipantOptions
  class KitHire < EventCustomerParticipantOption

    belongs_to :kit_hire, :class_name => "ExtraEvents::KitHire"
    has_one :sale_product, conditions: { sale_productable_type: 'EventCustomerParticipantOptions::KitHire' }, dependent: :destroy, foreign_key: :sale_productable_id

    attr_accessible :kit_hire_id, :event_customer_participant_id, :free, :created_at, :updated_at

    validates :kit_hire_id, existence: true, if: :free?

    def class_type
      self.class.name
    end

    def logo
      nil
    end

    def sku_code
      nil
    end

    def number_in_stock
      1
    end
  end
end
