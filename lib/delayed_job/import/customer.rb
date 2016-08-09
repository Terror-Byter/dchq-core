class DelayedJob::Import::Customer < Struct.new(:data, :store, :user, :params)
  def perform
    errors = []
    Customer.transaction do
      data.each_with_index do |record, index|
        next if index.zero?

        @c = store.company.customers.build
        @c.build_avatar
        @c.build_address
        @c.certification_level_memberships.build

        import( record )

        unless @c.save
          errors << "#{ I18n.t("controllers.on_line") } #{ index + 1 }: #{ @c.errors.full_messages.join(", ") }"
        end
      end
    end

    if errors.blank?
      ImportMailer.success(user, I18n.t('activerecord.models.customer.one')).deliver
    else
      ImportMailer.rejected(user, I18n.t('activerecord.models.customer.one'), errors).deliver
    end
  end

  private
  def import record
    record.each_with_index do |item, i|
      next if params["fields_#{i + 1}"].blank? || params["fields_#{i + 1}"] == "id" || item.blank?

      case params["fields_#{i + 1}"]
      when 'customer_experience_level_id' then @c[params["fields_#{i + 1}"]] = CustomerExperienceLevel.find_by_name(item).try(:id)
      when "first", "second", "city", "state", "post_code" then
        @c.address[params["fields_#{i + 1}"]] = item
      when 'country_code' then @c.address[params["fields_#{i + 1}"]] = CountrySelect::COUNTRIES.index(item)
      when "tags" then @c.tag_list = item.gsub(";", "  ")
      when "certification_agency_id" then @c.certification_level_memberships.first.certification_agency_id = CertificationAgency.find_by_name(item).try(:id)
      when "custom_fields" then
        item.split("|").each do |custom_field|
          field_value = custom_field.split(":")
          @c.custom_fields << @c.custom_fields.build(name: field_value.first, value: field_value.last)
        end
      when "certification_level_id" then
        begin
          @c.certification_level_memberships.first.certification_level_id = CertificationLevel.find_by_name_and_certification_agency_id(item, @c.certification_level_memberships.first.certification_agency_id).id
        rescue
          @c.certification_level_memberships.first.certification_level_id = nil
        end
      when "membership_number" then @c.certification_level_memberships.first.membership_number = item
      when "primary" then @c.certification_level_memberships.first.primary = item.to_bool
      when "send_event_related_emails" then @c.send_event_related_emails = item.to_bool
      when "certification_date" then @c.certification_level_memberships.first.certification_date = item
      when "notes" then
        item.split("|").each do |note|
          @c.notes << @c.notes.build(description: note, creator_id: user.id)
        end
      else @c[params["fields_#{i + 1}"]] = item
      end
    end
    @c.certification_level_memberships.clear if @c.certification_level_memberships.first.certification_level_id.blank?
  end
end
