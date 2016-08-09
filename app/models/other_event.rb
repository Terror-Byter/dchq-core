class OtherEvent < Event
  has_many :children, class_name: 'OtherEvent', foreign_key: "parent_id"

  belongs_to :event_trip
  belongs_to :parent, class_name: "OtherEvent", foreign_key: 'parent_id'

  attr_accessor :number_of_recurring_events_for_update
  attr_accessible :name, :event_type_id, :event_trip_id, :starts_at, :ends_at, :all_day, :frequency, :boat_id,
                  :location, :number_of_dives, :limit_of_registrations, :price, :instructions, :notes,
                  :additional_equipment, :private, :enable_booking, :number_of_recurring_events_for_update,
                  :number_of_frequencies

  validates :name, length: { maximum: 255 }, allow_blank: true
  validates :number_of_frequencies, numericality: { greater_than_or_equal_to: 0 }
  validates :event_trip, presence: true, if: ->(u){ u.event_type_id == 1 }

  after_save :create_recurring_event, if: ->(u){ u.new_record? || !u.recurring? }

  after_destroy :destroy_all_childrens
  after_update :update_recurring_events, if: ->(u){ u.recurring? }

  def cert
    if event_type.name.eql?("Dive Trip")
      "#{event_trip.try(:name)}"
    else
      event_type.name
    end
  end

  def get_future_recurring_events
    return children.future if parent_id.blank?
    start_time = self.starts_at
    parent_event = self.parent_id
    store.events.where{(parent_id.eq parent_event) & (starts_at.gt start_time)}
  end

  def child?
    false
  end

  private
  def create_recurring_event
    destroy_all_childrens

    frequency      = Frequency.frequencies[self.frequency]
    (1..number_of_frequencies - 1).each do |i|
      attributes = self.attributes
      attributes["starts_at"] = (self.starts_at + ( i * frequency[:number_of_days]).days).strftime("%d-%m-%Y %H:%M")
      attributes["ends_at"] = (self.ends_at + ( i * frequency[:number_of_days]).days).strftime("%d-%m-%Y %H:%M")
      attributes.delete("id")
      attributes["parent_id"] = self.id
      attributes["frequency"] = "One-off"
      attributes["number_of_frequencies"] = 0
      event = Event.new(attributes)
      event.save
    end
  end

  def destroy_all_childrens
    Event.destroy_all(parent_id: self.id)
  end

  def change_recurring_events events
    attr = {}
    attr = changes.keys.map{|key| attr.merge!(key.to_sym => changes[key].last)}.first
    starts_at_different = 0
    ends_at_different = 0
    if self.changes.keys.include?("starts_at")
      starts_at_different = changes["starts_at"].last - changes["starts_at"].first
      attr.delete("starts_at")
    end
    if self.changes.keys.include?("ends_at")
      ends_at_different = changes["ends_at"].last - changes["ends_at"].first
      attr.delete("ends_at")
    end
    events.each do |event|
      attr.merge!( { starts_at: event.starts_at + starts_at_different.seconds, ends_at: event.ends_at + ends_at_different.seconds } )
      event.update_attributes(attr)
    end
  end

  def update_recurring_events
    return if self.changes.blank? or number_of_recurring_events_for_update.to_i.zero?

    event_store_id, event_starts_at = store_id, starts_at
    event_parent_id = recurring_child? ? parent_id : id
    event_starts_at = changes["starts_at"].first if self.changes.keys.include?("starts_at")

    events = Event.where{(store_id.eq event_store_id) & (parent_id.eq event_parent_id) & (starts_at.gt event_starts_at)}.order(:starts_at).limit(self.number_of_recurring_events_for_update)

    change_recurring_events events
  end
end
