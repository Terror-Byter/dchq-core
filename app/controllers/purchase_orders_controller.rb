class PurchaseOrdersController < InheritedResources::Base
  decorates_assigned :purchase_order
  actions :show, :edit, :update, :destroy # borrowing only these actions from InheritedResources::Base
  respond_to :html, :js, :json # FIXME: specify proper only's and set |format| format. ... for all actions
  custom_actions resource: [
      :assign_supplier,
      :suppliers_list,
      :remove_supplier,
      :add_product,
      :products_list,
      :empty,
      :add_note,
      :download,
      :set_status,
      :update_order_form_after_send,
      :send_email_to_supplier,
      :set_expected_delivery,
      :update_amend
  ] # for InheritedResources
  before_filter :set_supplier_for_js, only: [:show]

  before_filter only: [:add_product, :assign_supplier, :remove_supplier, :empty, :update, :destroy] do |c|
    c.instance_eval { allow_only_for_statuses(:pending) }
  end

  before_filter only: [:add_note] do |c|
    c.instance_eval { allow_for_all_statuses_except(:received_in_full) }
  end

  before_filter only: [:send_email_to_supplier] do |c|
    c.instance_eval { allow_only_for_statuses(:pending, :received_in_part) }
  end

  before_filter only: [:set_expected_delivery] do |c|
    c.instance_eval { allow_only_for_statuses(:sent_to_supplier, :expecting_delivery) }
  end

  before_filter only: [:update_amend] do |c|
    c.instance_eval { allow_only_for_statuses(:received_in_part) }
  end

  #noinspection RailsChecklist01,RailsParamDefResolve
  def index
    @q = PurchaseOrder.includes([:supplier]).find_all_of_company(current_company.id).newest_first.ransack(params[:q])
    orders = @q.result

    render 'index', locals: {
      pending_po_cnt: orders.pending.count,
      sent_po_cnt: orders.sent_to_supplier.count,
      expecting_po_cnt: orders.expecting_delivery.count,
      received_po_cnt: orders.received.count,

      collection: orders.page(params[:page]).per(Figaro.env.default_pagination.to_i),
      total_cnt: orders.count,
    }
  end

  def show
    show! do
      @brands = current_store.brands
      @categories = current_store.categories
      @suppliers = current_company.suppliers
    end
  end

  def create
    @purchase_order = PurchaseOrder.create(
        current_user,
        current_company,
        params[:purchase_order][:supplier_id],
        params[:purchase_order][:delivery_location_id]
    )
    if @purchase_order.errors.empty?
      redirect_to purchase_order_path(@purchase_order)
    else
      redirect_to purchase_orders_path, alert: I18n.t('controllers.purchase_orders.flash.create.error_creating_order')
    end
  end

  def edit
    edit! do |format|
      format.html { redirect_to purchase_order_path(@purchase_order) }
    end
  end

  # TODO: move to SupplierController
  def suppliers_list
    render json: current_company.suppliers.search(params[:term]).as_json(methods: :label, only: [:id, :label])
  end

  def assign_supplier
    assign_supplier! do
      if @purchase_order.assign_supplier(params[:supplier_id])
        render 'assign_supplier'
      else
        render json: @purchase_order.errors, status: :unprocessable_entity
      end
      return # to avoid built-in render
    end
  end

  def remove_supplier
    remove_supplier! do
      if @purchase_order.remove_supplier()
        head :ok
      else
        render json: @purchase_order.errors, status: :unprocessable_entity
      end
      return # to avoid built-in render
    end
  end

  def add_product
    add_product! do
      @purchase_order_item = @purchase_order.add_product(current_store, params[:product_id], params[:quantity])
      if @purchase_order_item.errors.empty?
        @purchase_order_item = @purchase_order_item.decorate # decorate just before render
        render 'add_product'
      else
        render json: @purchase_order_item.errors, status: :unprocessable_entity
      end
      return # to avoid built-in render
    end
  end

  def products_list
    products_list! do |format|
      format.json do
        products = current_store.products.unarchived.search(params[:term])
        if params.has_key? :supplier_id
          products = products.filter_by_supplier(params[:supplier_id])
        end
        render json: @purchase_order.
          select_allowed_products(products.all).
            as_json(methods: :label, only: [:id, :label])
      end
    end
  end

  def empty
    empty! do
      @purchase_order.empty
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html do
        redirect_to purchase_orders_path, notice: I18n.t('controllers.purchase_orders.flash.destroy.success')
      end
      failure.html do
        flash[:alert] = I18n.t('controllers.purchase_orders.flash.destroy.error')
        render 'edit'
      end
    end
  end

  def add_note
    add_note! do
      if @purchase_order.add_note(params[:note])
        if @purchase_order.note.blank?
          render 'delete_note'
        else
          render 'add_note'
        end
      else
        render json: @purchase_order.errors, status: :unprocessable_entity
      end
      return
    end
  end

  def set_status
    set_status! do |format|
      @purchase_order.status = params[:status]
      success = @purchase_order.mark_received_on_current_status! false # don't raise error on wrong status
      success = @purchase_order.save unless success # not in any of the 'received' states

      format.json do
        if success
          render json: [{status: 'ok'}], status: :ok # NOTE: don't use head :ok here
        else
          render json: @purchase_order.errors, status: :unprocessable_entity
        end
      end
      format.html do
        redir_params = {}
        unless success
          redir_params[:alert] = @purchase_order.errors
        end

        redirect_to purchase_order_path(@purchase_order), redir_params
      end
    end
  end

  #noinspection RailsChecklist01
  def download
    download! do
      pdf = WickedPdf.new.pdf_from_string(render_to_string(file: 'pdf/purchase_orders/show', layout: false))
      send_data pdf,
                filename: "Purchase order #{@purchase_order.id}.pdf",
                type: 'application/pdf',
                disposition: 'attachment'

      return # to prevent render
    end
  end

  def send_email_to_supplier
    send_email_to_supplier! do |format|
      format.html do
        if @purchase_order.send_email_to_supplier(
            params[:purchase_order][:email],
            current_store,
            params[:purchase_order][:status] # can be nil
        )
          options = {notice: I18n.t('controllers.purchase_orders.flash.send_email_to_supplier.success')}
        else
          if @purchase_order.errors.empty? # email delivery error
            errors = I18n.t('controllers.purchase_orders.flash.send_email_to_supplier.error')
          else # model validation errors
            errors = @purchase_order.errors.full_messages
          end
          options = {alert: errors}
        end

        redirect_to purchase_order_path(@purchase_order), options
      end
    end
  end

  def set_expected_delivery
    set_expected_delivery! do |format|
      format.js do
        if @purchase_order.set_expected_delivery(params[:purchase_order][:expected_delivery])
          render 'set_expected_delivery'
        else
          head :unprocessable_entity
        end
      end
    end
  end

  def update_amend # define it explicitly because we need 'update' functionality and @purchase_order defined
    update! do |format|
      format.js do
        render 'update_amend'
      end
    end
  end

  private

  def allow_only_for_statuses(*statuses)
    @purchase_order = PurchaseOrder.find(params[:id])

    unless statuses.include?(@purchase_order.status.to_sym)
      raise SecurityError,
            "Purchaser order status must be one of '[#{statuses.join(', ')}]', " <<
            "got '#{@purchase_order.status}' for order with id = '#{@purchase_order.id}'"
    end
  end

  def allow_for_all_statuses_except(*statuses)
    allow_only_for_statuses(*PurchaseOrder.status.values.map(&:to_sym).reject{ |x| statuses.include? x })
  end

  def set_supplier_for_js
    @purchase_order = PurchaseOrder.find(params[:id])

    unless @purchase_order.supplier.nil?
      gon.supplier_id = @purchase_order.supplier.id
    end
  end
end