class SettingsController < InheritedResources::Base

  before_filter :init_hominid, only: [:edit_mailchimp_step_2]
  before_filter :check_current_user_access, except: [:index, :user_profile]
  before_filter :check_access_to_clear_data, only: [:clear_data, :clear_data_page]

  defaults resource_class: Company
  respond_to :html
  actions :index, :update, :edit
  custom_actions collection: [:user_profile, :stores, :update_stores, :update_store,
                              :sales, :events, :update_events, :integrations, :update_integrations,
                              :select_agency, :edit_agency, :update_agency,
                              :trips, :additionals, :edit_mailchimp_step_1, :edit_mailchimp_step_2,
                              :print, :import_to_csv_step_1, :import_to_csv_step_2, :import,
                              :switch_store, :servicing, :boats, :emails, :email_example,
                              :update_user, :clear_data_page, :clear_data, :rentals, :restore_sale]

  def switch_store
    render layout: 'overlay'
  end

  def servicing
    redirect_to root_path, alert: I18n.t('controllers.settings.no_access') unless can? :manage, Service
  end

  def import_to_csv_step_2
    if params[:import_type] != 'Eve'
      session[:import] = {}
      begin
        session[:import][:data] = CSV.parse params[:file].read, row_sep: :auto
      rescue
        flash[:alert] = I18n.t('controllers.settings.incorrect_delimiter')
        redirect_to :back and return
      end
    end

    case params[:import_type]
    when 'Customer'         then
      @fields = Customer.field_names
      session[:import][:type] = "Customer"
    when 'Supplier'         then
      @fields = Supplier.field_names
      session[:import][:type] = "Supplier"
    when 'BusinessContact'  then
      @fields = BusinessContact.field_names
      session[:import][:type] = "BusinessContact"
    when 'Product'  then
      @fields = Product.field_names
      session[:import][:type] = "Product"
    when 'RentalProduct'  then
      @fields = RentalProduct.field_names
      session[:import][:type] = "RentalProduct"
    when 'Eve' then
      file_path = Rails.root.join('import', "#{Time.now.to_f}#{File.extname(params[:file].original_filename)}")
      File.open(file_path, 'wb') do |file|
        file.write(params[:file].read)
      end
      Delayed::Job.enqueue(DelayedJob::Import::Eve.new(file_path.to_s, current_store, current_user))

      redirect_to import_to_csv_step_1_settings_path, notice: I18n.t("controllers.settings.import_notice", type: params[:import_type].tableize.humanize.downcase)
    else
      redirect_to :back, error: I18n.t("controllers.incorrect_file_type")
    end
  end

  def import
    Delayed::Job.enqueue "DelayedJob::Import::#{session[:import][:type]}".constantize.new(session[:import][:data],
                                                                                          current_store,
                                                                                          current_user,
                                                                                          params)

    redirect_to import_to_csv_step_1_settings_path, notice: I18n.t("controllers.settings.import_notice", type: session[:import][:type].tableize.humanize.downcase)
    session.delete(:import)
  end

  def update_agency
    @certification_agency = CertificationAgency.find_by_id(session[:choosen_agency_id])
    if @certification_agency.update_attributes(params[:certification_agency])
      session[:choose_agency_id] = nil
      flash[:notice] = I18n.t("controllers.certification_level")
      redirect_to select_agency_settings_path
    else
      @certification_levels = CertificationLevel.where(store_id: current_store.id, certification_agency_id: session[:choose_agency_id])
      render action: :edit_agency
    end
  end

  def edit_agency
    params[:id] ||= session[:choosen_agency_id]
    redirect_to settings_path, alert: I18n.t("controllers.you_have_to_choose_agency") if params[:id].blank?
    @certification_agency = CertificationAgency.find_by_id(params[:id])
    @certification_levels = @certification_agency.certification_levels.added_by_admin.order(:id) +
      @certification_agency.certification_levels.where(store_id: current_store.id).order(:id)
    session[:choosen_agency_id] = params[:id]
  end

  def update
    params[:company].delete(:logo_attributes) if params[:company][:logo_attributes]['image'].blank?
    update! do |success, failure|
      success.html do
        redirect_to action: :edit
      end
      failure.html do
        render action: :edit
      end
    end
  end

  def update_stores
    update! do |success, failure|
      success.html do
        redirect_to stores_settings_path, notice: I18n.t("controllers.update_stores")
      end
      failure.html do
        render action: :stores
      end
    end
  end

  def update_store
    params[:store][:email_setting_attributes].parse_time_select! :time_to_send_event_reminder  if params[:store] && params[:store][:email_setting_attributes]
    if current_store.update_attributes(params[:store])
      redirect_to params[:back_url], notice: params[:notice]
    else
      render action: params[:back_action].to_sym
    end
  end

  def update_user
    if current_user.update_attributes(params[:user])
      redirect_to params[:back_url], notice: params[:notice]
    else
      render action: params[:back_action].to_sym
    end
  end

  def email_example
    I18n.locale = current_store.email_setting.language
    case params[:type]
    when 'booking_confirmed' then render template: "emails_examples/booking_confirmed", layout: false
    when 'event_reminder' then render template: "emails_examples/event_reminder", layout: false
    when 'online_event_booking' then render template: "emails_examples/online_event_booking", layout: false
    when 'sales_receipt' then render template: "emails_examples/sales_receipt", layout: false
    when 'rental_receipt' then render template: "emails_examples/rental_receipt", layout: false
    when 'service_ready_for_collection' then render template: "emails_examples/service_ready_for_collection", layout: false
    else raise "Template not found!"
    end
  end

  def clear_data
    available_clear_resources = %w(sales events customers)

    if params[:resources]
      params[:resources].each do |res|
        next unless available_clear_resources.include?(res)
        if res == 'customers'
          current_company.customers.destroy_all
        else
          current_store.send(res).destroy_all
        end
      end
    end
    redirect_to settings_path, notice: I18n.t('controllers.settings.clear_data_success', data: "#{params[:resources].map{ |u| u.titleize }.join(', ') if params[:resources]}" )
  end

  def restore_sale
    current_store.send("#{ params[:type].underscore }s").with_deleted.find(params[:id]).recover
    redirect_to :back, notice: 'Restored'
  end

  protected
  def resource
    current_company
  end

  def collection
    current_company
  end

  def init_hominid
    @mailchimp = Gibbon::API.new current_user.mailchimp_api_key
  end

  def check_access_to_clear_data
    redirect_to settings_path, alert: I18n.t('controllers.settings.no_access') if current_user != current_company.owner
  end
end
