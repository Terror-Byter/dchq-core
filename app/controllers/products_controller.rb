class ProductsController < InheritedResources::Base
  decorates_assigned :product, :products
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  load_and_authorize_resource

  respond_to :html
  respond_to :js, only: :destroy
  respond_to :json, only: [:index, :create]
  before_filter :set_tax_rate_type_for_js, only: [:new, :edit, :create, :update, :show]
  custom_actions collection: [:create_extra_option, :export, :barcode_export],
                 resource: [:print_barcode, :archived, :unarchived]

  def index
    index! do |format|
      format.json{ render json: current_store.products.as_json(methods: :label, only: [:id, :label]) }
    end
  end

  def update
    params[:product].delete(:logo_attributes) if params[:product][:logo_attributes]['image'].blank?
    super
  end

  def create_extra_option
    case params[:type]
    when 'brand' then
      @resource = current_store.brands.build(name: params[:name])
    when 'category' then
      @resource = current_store.categories.build(name: params[:name])
    when 'supplier' then
      @resource = current_company.suppliers.build(name: params[:name])
    end
    @resource.save
    respond_to do |format|
      format.js
    end
  end

  def export
    Delayed::Job.enqueue DelayedJob::Export::Product.new(current_store, current_user)
    redirect_to collection_path, notice: I18n.t('controllers.export_flash', type: I18n.t('activerecord.models.product.one'))
  end

  def barcode_export
    Delayed::Job.enqueue DelayedJob::Export::ProductBarcode.new(current_store, current_user)
    redirect_to collection_path, notice: I18n.t('controllers.export_flash', type: I18n.t('controllers.products.product_barcode'))
  end

  def print_barcode
    if current_store.barcode_printing_type == 'a4'
      barcodes = CSV.generate do |csv|
        csv << Product.field_names_barcode_export.map(&:last)
        params[:quantity].to_i.times do
          csv << [resource.name, resource.category.name, resource.sku_code, resource.barcode, formatted_currency(resource.retail_price), resource.description]
        end
      end
      send_data barcodes, type: 'text/csv; charset=utf-8; header=present', filename: "barcodes. Product #{resource.name}.csv"
    else
      label = ZebraPrinter::StandardLabel.new
      label.number_of_labels = params[:quantity]
      label.draw_multi_text(resource.barcode)
      send_data label.print, filename: "barcode.zpl"
    end
  end

  def archived
    resource.archived!
    redirect_to resource, notice: I18n.t('controllers.products.archived')
  end

  def unarchived
    resource.unarchived!
    redirect_to resource, notice: I18n.t('controllers.products.unarchived')
  end

  protected
  def begin_of_association_chain
    current_store
  end

  def collection
    filter = params[:filter].present? && params[:filter] == 'archived' ? :archived : :unarchived
    @q = end_of_association_chain.includes([:brand, :category, :supplier]).send(filter).ransack(params[:q])
    @products = @q.result.page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end

  def set_tax_rate_type_for_js
    gon.tax_rate_inclusion = current_store.tax_rate_inclusion
  end

  def build_resource
    super.tap do |attr|
      attr.build_logo unless attr.logo
    end
  end
end
