class SuppliersController < InheritedResources::Base
  decorates_assigned :supplier, :suppliers
  include Mailchimp

  respond_to :html
  respond_to :csv, only: :export

  custom_actions collection: [:sync_with_mailchimp, :export]
  before_filter :check_able_remove_resource, only: [:destroy]

  def update
    params[:supplier].delete(:logo_attributes) if params[:supplier][:logo_attributes] and params[:supplier][:logo_attributes]['image'].blank?
    super
  end

  def sync_with_mailchimp
    collection.each do |record|
      begin
        sync_mailchimp record
      rescue Exception => e
        flash[:error] = I18n.t("controllers.sync_failed", message: e.message, id: record.id)
        break
      end
    end
    flash[:notice] = I18n.t("controllers.business_sync_ok") if flash[:error].blank?
    redirect_to collection_path
  end

  def export
    if params[:export_type] == "Supplier"
      Delayed::Job.enqueue DelayedJob::Export::Supplier.new(current_store, current_user)
      flash[:notice] = I18n.t('controllers.export_flash', type: I18n.t('activerecord.models.supplier.one'))

    elsif params[:export_type] == "Business Contact"
      Delayed::Job.enqueue DelayedJob::Export::BusinessContact.new(current_store, current_user)
      flash[:notice] = I18n.t('controllers.export_flash', type: I18n.t('activerecord.models.business_contact.one'))
    end
    redirect_to collection_path
  end

  protected
  def begin_of_association_chain
    current_company
  end

  def collection
    @q = end_of_association_chain.includes([:address, :tags]).ransack(params[:q])
    @suppliers = @q.result.page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end

  def build_resource
    super.tap do |attr|
      attr.build_address unless attr.address
      attr.build_logo unless attr.logo
    end
  end

  def check_able_remove_resource
    redirect_to resource, alert: I18n.t("controllers.you_cant_remove_resource") if !current_user.manager? or !resource.can_be_deleted?
  end
end
