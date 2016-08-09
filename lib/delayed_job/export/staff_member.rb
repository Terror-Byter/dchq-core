class DelayedJob::Export::StaffMember < Struct.new(:store, :user)
  def perform
    filename = "Staff Export - #{Time.now.strftime("%d/%m/%Y %I:%M%p")}.csv"

    staff_members = CSV.generate do |csv|
      csv << User.field_names.map(&:last)

      store.company.users.find_each do |s|
        p  = s
        a  = s.address
        csv << [s.email, s.time_zone, s.role, s.current_step,
                p.given_name, p.family_name, p.alternative_email, p.telephone, p.emergency_contact_details, p.available_days_for_export,
                p.contracted_hours, a.first, a.second, a.city, a.state, a.country_name, a.post_code
               ]
      end
    end

    ExportMailer.success(staff_members, filename, I18n.t('activerecord.models.staff_member.one'), user).deliver
  end
end
