class PurchaseOrderMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def supplier_email(purchase_order, current_store)
    @purchase_order    = purchase_order.decorate
    @current_store = current_store
    @current_company   = current_store.company
    I18n.locale = current_store.email_setting.language
    return unless @purchase_order.supplier.email.present?

    mail(
      to: @purchase_order.supplier.email,
      from: %("#{@current_store.store.name}" <#{@current_store.company.outbound_email}>),
      subject: t(
        'mailer.purchase_order_mailer.supplier_email.subject',
        number: @purchase_order.id,
        company: @current_store.company.name
      )
    )
  end
end
