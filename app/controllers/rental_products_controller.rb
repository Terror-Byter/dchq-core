class RentalProductsController < InheritedResources::Base
  decorates_assigned :rental_product, :rental_products

  respond_to :html, expect: [:search]
  respond_to :json, only: [:search]
  actions :all
  custom_actions resource: [:archived, :unarchived], collection: [:search, :export]

  def archived
    resource.archived!
    redirect_to resource, notice: I18n.t('controllers.rental_products.archived')
  end

  def unarchived
    resource.unarchived!
    redirect_to resource, notice: I18n.t('controllers.rental_products.unarchived')
  end

  def search
    rental = Rental.find(params[:rental_id])

    render json: end_of_association_chain.
      includes(renteds: :rental).
      unarchived.search(params[:term]).
      select {|rp| (rp.number_in_stock - rp.renteds.select{|r| r.rental.return_date > rental.pickup_date}.map{|r| r.quantity}.sum) > 0}
      .as_json(methods: [:label])
  end

  def export
    Delayed::Job.enqueue DelayedJob::Export::RentalProduct.new(current_store, current_user)
    redirect_to collection_path, notice: I18n.t('controllers.export_flash', type: I18n.t('activerecord.models.rental_product.one'))
  end

  protected
  def begin_of_association_chain
    current_store
  end

  def collection
    filter = params[:filter].present? && params[:filter] == 'archived' ? :archived : :unarchived
    @q = end_of_association_chain.send(filter).ransack(params[:q])
    @q.sorts = 'id desc' if @q.sorts.empty?
    @rental_products = @q.result.page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end

  def build_resource
    super.tap do |attr|
      attr.build_logo unless attr.logo
    end
  end
end
