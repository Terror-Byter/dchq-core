class StoreMailer < ActionMailer::Base
  default from: Devise.mailer_sender

  def remind_product store, products
    @store = store
    @products = products
    I18n.locale = store.email_setting.language
    return unless store.company.owner.email.present?

    mail :to => store.company.owner.email, :subject => I18n.t("mailer.store_mailer.remind_product_subject")
  end
end
