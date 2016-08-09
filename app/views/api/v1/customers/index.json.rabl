collection :@customers

attributes :id, :given_name, :family_name, :born_on, :gender, :email, :send_event_related_emails, :telephone, :mobile_phone, :source,
           :default_discount_level, :tax_id, :zero_tax_rate, :tag_list, :emergency_contact_details, :hotel_name, :room_number,
           :customer_experience_level_id, :last_dive_on, :number_of_logged_dives, :fins, :bcd, :wetsuit, :weight

child(:company){ attributes :id, :name }
child(:address){ attributes :id, :first, :second, :city, :state, :country_code, :post_code }
child(:custom_fields){ attributes :id, :name, :value }
