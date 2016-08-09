class DelayedJob::Export::Customer < Struct.new(:store, :user, :customer_list)
  def perform

    #TO ADD .encode('iso-8859-1', undef: :replace, replace: ''), :type => 'text/csv; charset=iso-8859-1; header=present'

    filename = "Customer Export - #{Time.now.strftime("%d/%m/%Y %I:%M%p")}.csv"
    customers = CSV.generate do |csv|
      csv << Customer.field_names.map(&:last)

      customer_list.each do |c|
        clm = c.certification_level_memberships.first
        csv << [c.customer_experience_level.try(:name),
                c.given_name,
                c.family_name,
                c.default_discount_level,
                c.source,
                c.telephone,
                c.mobile_phone,
                c.email,
                c.fins,
                c.bcd,
                c.wetsuit,
                c.number_of_logged_dives,
                c.born_on,
                c.last_dive_on,
                c.hotel_name,
                c.room_number,
                c.address.first,
                c.address.second,
                c.address.city,
                c.address.state,
                c.address.country_name,
                c.address.post_code,
                c.gender,
                c.tags.join(";"),
                clm.try(:certification_agency_export),
                clm.try(:certification_level_export),
                clm.try(:membership_number_export),
                clm.try(:certification_date_export),
                clm.try(:primary?).to_s,
                c.emergency_contact_details,
                c.fins_own?.to_s,
                c.bcd_own?.to_s,
                c.wetsuit_own?.to_s,
                c.mask_own?.to_s,
                c.regulator_own?.to_s,
                c.weight, c.custom_fields_for_export,
                c.notes_for_export,
                c.send_event_related_emails.to_s,
                c.tax_id,
                c.zero_tax_rate
               ]
      end
    end


    ExportMailer.success(customers, filename, I18n.t('activerecord.models.customer.one'), user).deliver
  end
end
