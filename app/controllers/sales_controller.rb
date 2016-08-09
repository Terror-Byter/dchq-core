class SalesController < InheritedResources::Base
  decorates_assigned :sale, :sales
  helper_method :can_change_complete_sale?

  respond_to :html, :js, :json
  #TODO: introduce same actions to constant
  custom_actions resource: [:empty, :customers_list, :add_customer, :products_list, :add_product, :history, :mark_as_complete, :export_to_csv,
                            :refund, :reopen_layby, :add_events, :add_customer_form, :add_product_form, :add_note, :add_misc_product],
                 collection: [:pay_for_event, :send_receipt_via_email, :show_email_receipt_form, :close, :event_tariffs]
  before_filter :find_sale, only: [:update, :edit, :empty, :destroy, :customers_list, :add_customer, :add_product, :mark_as_complete,
                                   :refund, :reopen_layby, :add_events, :search_product, :add_misc_product]
  before_filter :reject_refund_sale, only: [:edit, :update]
  before_filter :check_is_store_close, except: [:history, :close, :open, :show, :send_receipt_via_email]

  def history
    @q = current_store.sales.includes([:customers, :creator]).newest_first.ransack(params[:q])
    @sales = @q.result.page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end

  def update_extra_options
    if current_store.update_attributes(params[:store])
      redirect_to params[:back_url], notice: params[:message]
    else
      render action: params[:store].first[0].gsub("_attributes", "").to_sym
    end
  end

  def add_customer_form
    render layout: "overlay"
  end

  def add_product_form
    render layout: "overlay"
  end

  def show_email_receipt_form
    @sale = current_store.sales.find_by_id(params[:id])
    render layout: "overlay"
  end

  def show
    redirect_to edit_sale_path(resource) and return if resource.outstanding?
    show! do
      resource.customers << current_company.default_customer if resource.customers.blank?
    end
  end

  def edit
    edit! do
      resource.customers << current_company.default_customer if resource.customers.blank?
    end
  end

  def index
    create_sale if default_sale_list.empty?
    @sale ||= default_sale_list.first
    @sale.sale_customers.create(:customer => current_company.default_customer) if @sale.customers.blank?
  end

  def new
    respond_to do |format|
      unless default_sale_list.available_limit_exceeded?
        create_sale
        @sale || default_sale_list.first
          format.js
          format.html{ redirect_to edit_sale_path(@sale) }
      else
        format.js do
          render template: "sales/available_limit_exceeded.js.erb"
        end
        format.html do
          redirect_to sales_path, alert: "You've exceeded the limit for open sales carts. Please complete a sale."
        end
      end
    end

    @sale || default_sale_list.first
  end

  def empty
    return unless @sale.active?
    @sale.empty!
    respond_to do |format|
      format.js
      format.html
    end
  end

  def destroy
    if can_change_complete_sale? || @sale.active? || @sale.refunded?
      @sale.destroy

      #FIXME: remove hack
      @sale = @is_pos_card_referer_sales ? (default_sale_list.last || create_sale) : nil

      respond_to do |format|
        format.js
        format.html{ redirect_to history_sales_path, notice: I18n.t('controllers.sales.destroy') }
      end
    end
  end

  def customers_list
    render json: current_company.customers.exclude_with(@sale).search(params[:term]).as_json(methods: :label)
  end

  def add_customer_form
    render layout: 'overlay'
  end

  def add_customer
    if can_change_complete_sale? || ( @sale.active? && @sale.has_only_walkin? )
      @sale_customer = @sale.sale_customers.create(customer_id: params[:customer_id]) unless @sale.refunded?
      @sale.update_amounts!

      # FIXME: render this flash using js
      render template: 'sales/add_customer.js.haml'
    end
  end

  def products_list
    result = current_store.products.in_stock.unarchived.search(params[:term]).as_json(methods: [:label, :class_type]) +
             current_company.gift_card_types.enable_sold.search(params[:term]).as_json(methods: [:label, :class_type])
    render json: result
  end

  def search_product
    search_result = current_store.products.unarchived.search(params[:barcode]).first ||
      current_company.gift_card_types.enable_sold.find_by_uniq_id(params[:barcode])
    unless search_result.blank?
      prepare_values_for_add_product search_result
      add_product
    else
      render template: "sales/add_product_error.js.haml"
    end
  end

  def add_product
    prepare_gift_card if params[:class_type].eql?("GiftCardType")
    sale_product = @sale.sale_products.find_by_sale_productable_id_and_sale_productable_type(params[:product_id], params[:class_type]) unless params[:class_type].eql?("GiftCardType")
    if sale_product
      sale_product.update_attribute :quantity, sale_product.quantity.next unless @sale.refunded?
    else
      product = params[:class_type].constantize.find(params[:product_id])

      @sale.sale_products.create(
        sale_productable_type: params[:class_type],
        sale_productable_id: params[:product_id],
        price: product.unit_price
      ) unless @sale.refunded?
    end
    render template: "sales/add_product.js.haml"
  end

  def mark_as_complete
    if @sale.can_be_completed? || @sale.can_be_outstanding?
      @sale.delay.freeze_product_prices
      @sale.delay.update_attributes!  taxable_revenue: @sale.send(:calc_taxable_revenue),
                                      cost_of_goods: @sale.send(:calc_cost_of_goods)

      @sale.event_customer_participants.each do |ecp|
        ecp.update_column( :smart_line_item_price, ecp.grand_total_price )
      end

      @sale.sale_products.each do |sp|
        if sp.sale_productable_type == 'Service'
          sp.update_column :smart_line_item_price, sp.sale_productable.try(:grand_total).to_f
        else
          sp.update_column :smart_line_item_price, sp.line_item_price
        end
      end

      @sale.update_attributes(status: params[:status]) and @sale.update_gift_cards_status
      @sale.update_column :completed_at, Time.now if params[:status] == 'complete_refund' || params[:status] == 'complete'
      @sale.sale_products.where(sale_productable_type: 'StoreProduct').update_all(sale_productable_type: 'Product')
      @sale.send_xero
      @sale.send_scubatribe
    end

    respond_to do |format|
      format.html { redirect_to @sale }
      format.js { render js: "window.location = '#{sale_path(@sale)}'" }
    end
  end

  def reopen_layby
    @sale.update_attributes(status: "layby") if @sale.complete_layby?
    respond_to do |format|
      format.html{ redirect_to edit_sale_path(@sale) }
      format.js { render js: "window.location = '#{edit_sale_path(@sale)}'" }
    end
  end

  def refund
    sale_products = SaleProduct.find(params[:sale_product_id])

    sale_products.each do |sp|
      if sp && sp.sale_productable_type == 'EventCustomerParticipant'
        EventCustomerParticipant.update_all({need_show: false}, {id: @sale.event_customer_participants.map(&:id)} )
      end
    end

    @refunded_sale = @sale.refund!(params.slice(:sale_product_id, :refund_quantity))

    respond_to do |format|
      format.html{ redirect_to edit_sale_path(@refunded_sale) }
      format.js { render js: "window.location = '#{edit_sale_path(@refunded_sale)}'" }
    end
  end

  def add_events
    @sale.add_events!(ecp_id: params[:ecp_id])
  end

  def pay_for_event
    @ecp = EventCustomerParticipant.find(params[:ecp_id])
    customer_id = @ecp.customer ? @ecp.customer.id : nil
    @sale = params[:sale_id].blank? ? create_sale(customer_id) : current_store.sales.find(params[:sale_id].to_i)
    @sale.add_events!(ecp_id: @ecp.id, customer_id: params[:customer_id].to_i)
    discount = @sale.build_discount(
      kind: 'percent',
      value: @ecp.try(:customer).try(:default_discount_level).blank? ? '0' : @ecp.customer.default_discount_level
    )
    discount.save
    @sale.update_amounts!

    respond_to do |format|
      format.html { redirect_to edit_sale_path(@sale) }
      format.js { render js: "window.location = '#{edit_sale_path(@sale)}'" }
    end
  end

  def send_receipt_via_email
    if @sale = current_store.sales.find_by_id(params[:id])
      params[:email].split(", ").each do |email|
        pdf = WickedPdf.new.pdf_from_string(render_to_string('sale_mailer/send_receipt', layout: false, locals: { for_pdf: true }))
        SaleMailer.delay.send_receipt(@sale, params[:email], pdf_file: pdf)
      end
      flash[:notice] = I18n.t("controllers.receipt_send")
    else
      flash[:error] = I18n.t("controllers.receipt_not_send")
    end
    redirect_to @sale.complete? ? sale_path(@sale) : edit_sale_path(@sale)
  end

  def update
    update! do |success, failure|
      if !params[:payment_type].blank? and resource.errors.blank? and @sale.refund?
        redirect_to mark_as_complete_sale_path(@sale, status: "complete_refund") and return
      end
    end
  end

  def close
    redirect_to sales_path unless current_store.close?
  end

  def add_note
    @sale = current_store.sales.find_by_id(params[:id])
    if @sale.update_attributes(note: params[:note])
      if @sale.note.blank?
        render 'delete_note'
      else
        render 'add_note'
      end
    else
      render json: @sale.errors
    end
  end

  def add_misc_product
    @product = current_store.miscellaneous_products.create(params[:misc_product])
    unless @product.new_record?
      @sale.sale_products.create(sale_productable_id: @product.id, sale_productable_type: @product.class.name, quantity: 1)
    end
    render template: "sales/add_misc_product.js.haml"
  end

  def export_to_csv
    start_date = params[:start_date].presence || Date.today - 5.years
    end_date = end_date.presence || Date.today

    Delayed::Job.enqueue DelayedJob::Export::Sale.new(current_store, current_user, start_date, end_date)
    redirect_to collection_path, notice: I18n.t('controllers.export_flash', type: I18n.t('activerecord.models.sale.one'))
  end

  protected
  def begin_of_association_chain
    current_store
  end

  def find_sale
    @sale = current_store.sales.includes(
      :customers, sale_products: [:sale_productable, :prod_discount, :product]
    ).find_by_id(params[:id])

    redirect_to root_path, alert: I18n.t('controllers.sales.sale_not_found') unless @sale
  end

  def reject_refund_sale
    @sale ||= resource
    redirect_to sale_path(@sale) unless @sale.outstanding?
  end

  def prepare_values_for_add_product(search_result)
    if search_result.class == GiftCardType
      search_result = search_result.create_gift_card
    end
    params[:product_id] = search_result.id
    params[:class_type] = search_result.class.name
  end

  def prepare_gift_card
    gift_card_type = GiftCardType.find(params[:product_id])
    params[:class_type] = "GiftCard"
    params[:product_id] = gift_card_type.create_gift_card.id
  end

  def add_credit_note
    #add credit note
    CreditNote.create(customer_id: @sale.customers.first.id,
                                    sale_id: @sale.id,
                                    initial_value: @sale.grand_total.abs,
                                    remaining_value: @sale.grand_total.abs
                                   )
    @sale.customers.first.update_attributes credit_note: @sale.customers.first.credit_note + @sale.grand_total.abs
  end

  def check_is_store_close
    redirect_to close_sales_path if current_store.close?
  end

  def can_change_complete_sale?
    @sale.complete? && !current_store.close? && current_user.manager? && @sale.children.blank?
  end
end
