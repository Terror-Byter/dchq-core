class DelayedJob::Import::Supplier < Struct.new(:data, :store, :user, :params)
  def perform
    errors = []
    Supplier.transaction do
      data.each_with_index do |record, index|
        next if index.zero?
        @supplier = Supplier.new(company: store.company)
        @supplier.build_address
        @supplier.build_logo

        import( record )

        unless @supplier.save
          errors << "#{I18n.t("controllers.on_line")} #{ index + 1 }: #{ @supplier.errors.full_messages.join(", ") }"
        end
      end
    end

    if errors.blank?
      ImportMailer.success(user, I18n.t('activerecord.models.supplier.one')).deliver
    else
      ImportMailer.rejected(user, I18n.t('activerecord.models.supplier.one'), errors).deliver
    end
  end

  private
  def import record
    record.each_with_index do |item, i|
      next if params["fields_#{i + 1}"].blank?

      case params["fields_#{i + 1}"]
      when "first", "second", "city", "state", "post_code" then @supplier.address[params["fields_#{i + 1}"]] = item
      when 'country_code' then @supplier.address[params["fields_#{i + 1}"]] = CountrySelect::COUNTRIES.index(item)
      else @supplier[params["fields_#{i + 1}"]] = item
      end

    end
  end
end
