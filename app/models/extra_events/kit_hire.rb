module ExtraEvents
  class KitHire < ExtraEvent
    belongs_to :kit_hire, :class_name => "ExtraEvents::KitHire"
  end
end
