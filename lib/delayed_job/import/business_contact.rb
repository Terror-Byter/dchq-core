class DelayedJob::Import::BusinessContact < Struct.new(:data, :store, :user, :params)
  def perform
    errors = []
    BusinessContact.transaction do
      data.each_with_index do |record, index|
        next if index.zero?
        @bc = BusinessContact.new
        @bc.build_avatar

        import( record )

        unless @bc.save
          errors << "#{I18n.t("controllers.on_line")} #{ index + 1 }: #{ @bc.errors.full_messages.join(", ") }"
        end
      end
    end

    if errors.blank?
      ImportMailer.success(user, I18n.t('activerecord.models.business_contact.one')).deliver
    else
      ImportMailer.rejected(user, I18n.t('activerecord.models.business_contact.one'), errors).deliver
    end
  end

  private
  def import record
    record.each_with_index do |item, i|
      next if params["fields_#{i + 1}"].blank?

      case params["fields_#{i + 1}"]
      when "supplier_id" then @bc[params["fields_#{i + 1}"]] = store.company.suppliers.find_by_name(item).id unless item.blank?
      else @bc[params["fields_#{i + 1}"]] = item
      end

    end
  end
end
