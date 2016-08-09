class DelayedJob::Export::BusinessContact < Struct.new(:store, :user)
  def perform
    filename = "Business Contact Export - #{Time.now.strftime("%d/%m/%Y %I:%M%p")}.csv"

    business_contacts = CSV.generate do |csv|
      csv << BusinessContact.field_names.map(&:last)

      BusinessContact.where(supplier_id: store.company.suppliers).each do |b|
        csv << [b.supplier.name, b.given_name, b.family_name, b.email, b.telephone, b.position, b.primary
        ]
      end
    end

    ExportMailer.success(business_contacts, filename, I18n.t('activerecord.models.business_contact.one'), user).deliver
  end
end
