module CustomersHelper
  def generate_events
    events = []

    grouped_events = current_store.events.future.not_those(@customer.events).includes(:store).to_a.group_by{ |e| e.boat_id }.to_a
    grouped_events.each do |gr|
      items = gr.last.map{ |i| i if (i.course? && i.parent?) || !i.course? }.compact.map{|e| [e.full_name, e.id]}
      boat = gr.first.blank? ? 'Not Assigned' : current_store.boats.find(gr.first).name
      events << [boat, items] unless items.blank?
    end

    events
  end
end
