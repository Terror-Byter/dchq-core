object :@customer

attributes :id, :given_name, :family_name, :born_on, :gender, :email, :send_event_related_emails, :telephone, :mobile_phone, :source,
           :default_discount_level, :tax_id, :zero_tax_rate, :tag_list, :emergency_contact_details, :hotel_name, :room_number,
           :customer_experience_level_id, :last_dive_on, :number_of_logged_dives, :fins, :bcd, :wetsuit, :weight

node(:avatar) { |customer| customer.avatar.image.url }

child(:address){ attributes :id, :first, :second, :city, :state, :country_code, :post_code }

child(:certification_level_memberships) do
  attribute :id, :membership_number, :certification_date, :primary
  child(:certification_level) do
    attribute :id, :name
    child(:certification_agency) { attribute :id, :name }
  end
end

node(:bcd) { |customer| "#{customer.bcd} (#{customer_equipment_to_human customer.bcd_own})"}
node(:fins) { |customer| "#{customer.fins} (#{customer_equipment_to_human customer.fins_own})"}
node(:wetsuit) { |customer| "#{customer.wetsuit} (#{customer_equipment_to_human customer.wetsuit_own})"}
node(:regulator) { |customer|  "(#{customer_equipment_to_human customer.regulator_own})"}
node(:mask) { |customer|  "(#{customer_equipment_to_human customer.mask_own})"}

child(:sales) do
  attributes :id, :created_at, :grand_total
  node(:products) do |sale|
    (sale.sale_products.map(&:name) + sale.events.map(&:name)).join(", ")
  end
end
