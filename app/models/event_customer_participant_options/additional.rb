module EventCustomerParticipantOptions
  class Additional < EventCustomerParticipantOption
    belongs_to :additional, class_name: "ExtraEvents::Additional"
    has_one :sale_product, conditions: { sale_productable_type: 'EventCustomerParticipantOptions::Additional' }, dependent: :destroy, foreign_key: :sale_productable_id
    attr_accessible :additional_id, :number_of_days

    def dynamic_quantity
      number_of_days.to_i
    end

    def attrs_for_clone
      super.merge({ number_of_days: self.number_of_days })
    end

    def class_type
      self.class.name
    end
  end
end
