class ServicesController < InheritedResources::Base
  decorates_assigned :service, :services
  load_and_authorize_resource
  respond_to :html, :js

  custom_actions collection: [:get_type_of_service, :add_item]
  before_filter :check_access_to_edit, only: [:edit, :update]
  before_filter :check_store_service_settings

  def get_type_of_service
    @type_of_services = []
    params[:service_id].split(',').each do |id|
      @type_of_services << Services::TypeOfService.find_by_id(id)
    end
  end

  def add_item
    @product = current_store.products.unarchived.find_by_id(params[:product_id])
  end

  def show
    super do |format|
      format.html do
        gon.SECONDS = resource.calculate_time_intervals
        gon.CONTINUE_TIMER = resource.continue?
      end
    end
  end

  def complete
    params[:send] ||= "false"

    if resource.grand_total.zero?
      resource.to_complete!
    else
      @sale = current_store.sales.active.find_by_id(params[:sale_id]) unless params[:sale_id].blank?
      create_sale(resource.customer_id) if @sale.blank?
      @sale.sale_products.create(sale_productable_type: "Service", sale_productable_id: resource.id)
      resource.update_sale_id!(@sale)

      discount = @sale.build_discount(
        kind: 'percent',
        value: resource.customer.default_discount_level
      )
      discount.save

      ServiceMailer.delay.servicing_collection(resource, @sale) if params[:send].eql?("true")
    end


    redirect_to resource.grand_total.zero? ? services_path : edit_sale_path(@sale)
  end

  protected
  def begin_of_association_chain
    current_store
  end

  def build_resource
    super.tap do |attr|
      attr.store_id = current_store.id
      attr.booked_in = Date.today
    end
  end

  def collection
    @services = case params[:filter]
                when nil, 'all' then end_of_association_chain
                else end_of_association_chain.send(params[:filter])
                end.includes([:user, :customer, :sale, :products, :store]).order('booked_in DESC').page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end

  def check_access_to_edit
    redirect_to service_path(resource), alert: I18n.t("controllers.cant_edit_service") if !resource.booked? and !resource.in_progress?
  end

  def check_store_service_settings
    redirect_to servicing_settings_path, alert: I18n.t("controllers.check_service_settings") unless current_store.has_service_settings?
  end
end
