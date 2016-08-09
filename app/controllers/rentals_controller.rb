class RentalsController < InheritedResources::Base
  actions :all, except: [:new]
  respond_to :html, except: [:create]
  respond_to :json, only: :create
  respond_to :js, only: [:add_rental_product, :update]
  custom_actions member: [:add_rental_product, :remove_payment, :send_receipt_via_email]
  before_filter :check_is_store_close, except: [:index]

  def show
    super do |format|
      format.html do
        if resource.layby? || resource.pay_pending?
          redirect_to action: :edit
        else
          render template: 'rentals/edit'
        end
      end
    end
  end

  def add_rental_product
    rental_product = current_store.rental_products.find_by_id(params[:rental_product_id]) || current_store.rental_products.find_by_barcode(params[:barcode])
    render template: 'rentals/add_rental_product_fail' and return unless rental_product

    exist_rentend = resource.renteds.find_by_rental_product_id(rental_product.id)
    if exist_rentend
      exist_rentend.update_attribute :quantity, exist_rentend.quantity.next
    else
      resource.renteds.create(rental_product: rental_product,
                              item_amount: rental_product.price_per_day,
                              tax_rate: rental_product.tax_rate.amount,
                              quantity: 1)
    end
  end

  def remove_payment
    resource.rental_payments.find_by_id(params[:rental_payment_id]).destroy
    render template: 'rentals/update'
  end

  def send_receipt_via_email
    pdf = WickedPdf.new.pdf_from_string(render_to_string(template: 'sale_mailer/send_rental_receipt', layout: false))
    SaleMailer.delay.send_rental_receipt(resource, params[:email], pdf_file: pdf)
    redirect_to resource, notice: I18n.t("controllers.receipt_send")
  end

  private
  def begin_of_association_chain
    current_store
  end

  def collection
    @rentals = case params[:filter]
               when nil, 'all' then end_of_association_chain
               else end_of_association_chain.send(params[:filter])
               end
    @q = @rentals.includes([:customer, :rental_payments]).ransack(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    @rentals = @q.result
    @rentals = @rentals.page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end

  def build_resource
    super.tap do |attr|
      attr.user = current_user
      attr.store = current_store
    end
  end

  def check_is_store_close
    redirect_to close_sales_path if current_store.close?
  end
end
