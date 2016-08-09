class DelayedJob::Export::Supplier < Struct.new(:store, :user)
  def perform
    filename = "Supplier Export - #{Time.now.strftime("%d/%m/%Y %I:%M%p")}.csv"

    suppliers = CSV.generate do |csv|
      csv << Supplier.field_names.map(&:last)
      store.company.suppliers.find_each do |s|
        csv << [s.name,
                s.telephone,
                s.email,
                s.address.first,
                s.address.second,
                s.address.city,
                s.address.state,
                s.address.country_name,
                s.address.post_code
        ]
      end
    end

    ExportMailer.success(suppliers, filename, I18n.t('activerecord.models.supplier.one'), user).deliver
  end
end
