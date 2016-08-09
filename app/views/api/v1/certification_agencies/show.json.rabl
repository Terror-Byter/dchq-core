object :@certification_agency

attributes :id, :name

node :certification_levels do
  @certification_agency.certification_levels_with_costs_for_store(current_store).map{ |u| { id: u.id, name: u.name } }
end
