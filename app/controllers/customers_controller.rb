class CustomersController < InheritedResources::Base
  decorates_assigned :customer, :customers
  include Mailchimp

  respond_to :html, :js
  respond_to :json, only: :update_certification_level_select
  respond_to :csv, only: :export
  custom_actions collection: [:search, :sync_with_mailchimp, :export, :export_to_qif, :check_certificate],
                 resource: [:get_credit_note, :add_to_event, :check_certification_levels, :get_discount_level,
                             :recalculate_event_price, :get_events, :load_sales, :load_ecp]

  before_filter :check_walk_in, only: [:edit, :update]
  skip_filter :authenticate_user!, only: [:update_certification_level_select, :create, :check_certificate]
  helper_method :params_perpage, :sort_column, :sort_direction

  def index
    if request.xhr?
      render partial: collection
    else
      super
    end
  end

  def update
    params[:customer].delete(:avatar_attributes) if params[:customer][:avatar_attributes] and params[:customer][:avatar_attributes]['image'].blank?
    super
  end

  def destroy
    if resource.walk_in? || !current_user.manager? || !resource.can_be_deleted?
      flash[:error] = I18n.t('customers.destroy.error')
      redirect_to resource_path
    else
      resource.destroy
      flash[:notice] = I18n.t('customers.destroy.notice')
      redirect_to collection_path
    end
  end

  def sync_with_mailchimp
    current_company.customers.with_email.without_walk_in.each do |record|
      begin
        sync_mailchimp record
      rescue Exception => e
        flash[:error] = I18n.t("controllers.sync_failed", message: e.message, id: record.id)
        break
      end
    end
    flash[:notice] = I18n.t("controllers.customer_sync_ok") if flash[:error].blank?
    redirect_to collection_path
  end

  def export
    Delayed::Job.enqueue DelayedJob::Export::Customer.new(current_store, current_user, current_company.customers)
    redirect_to collection_path, notice: I18n.t('controllers.export_flash', type: I18n.t('activerecord.models.customer.one'))
  end

  def export_to_qif
    buffer = StringIO.new
    Qif::Writer.new(buffer) do |writer|
      current_store.sales.where(created_at: params[:start_date].to_datetime..params[:end_date].to_datetime).each do |sale|
        writer << Qif::Transaction.new( date: sale.created_at,
                                        amount: sale.grand_total.to_f,
                                        memo: "#{I18n.t("controllers.sale_id")}: #{sale.receipt_id}; #{I18n.t("controllers.store")}: #{current_store.name}",
                                        payee: sale.customers.map(&:full_name).join(", ")
                                      )
      end
    end
    send_data buffer.string, type: "application/x-qw; charset=utf-8; header=present", filename: "Customer Financial - #{Time.now.strftime("%d/%m/%Y %I:%M%p")}.qif"
  end

  def search
    render json: current_company.search_people(params[:data])
  end

  def add_to_event
    redirect_to resource_path(resource), alert: "You didn't select any events" and return if params[:event_id].blank?
    params[:event_id].map{|id| resource.event_customer_participants.build(event_id: id)}
    if resource.save
      flash[:notice] = I18n.t("controllers.customer_added_to_event")
    else
      flash[:alert] = resource.errors.full_messages.join(", ")
    end
    redirect_to resource_path(resource)
  end

  def get_discount_level
    render text: resource.default_discount_level.to_f
  end

  def recalculate_event_price
    @event = current_store.events.find_by_id(params[:event_id])
  end

  def get_credit_note
    @sale = current_store.sales.find(params[:sale_id])
    payment = @sale.change.abs < resource.credit_note.abs ? @sale.change.abs : resource.credit_note.abs
    payment_method = current_store.get_credit_note_payment_method.id
    @sale.payments.create(cashier_id: current_user.id, customer_id: resource.id, amount: payment, payment_method_id: payment_method)
  end

  def check_certificate
    @customer = Customer.find_by_email params[:email]
  end

  protected
  def begin_of_association_chain
    current_company
  end

  def collection
    @q = end_of_association_chain.includes([:address, :certification_level_memberships]).ransack(params[:q])
    @customers = @q.result.page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end

  def build_resource
    super.tap do |attr|
      attr.build_address unless attr.address
      attr.build_avatar unless attr.avatar
    end
  end

  def check_walk_in
    @customer = current_company.customers.find_by_id(params[:id])
    redirect_to @customer and return if @customer.walk_in?
  end
end
