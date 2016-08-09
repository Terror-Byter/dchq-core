class CategoriesController < InheritedResources::Base
  decorates_assigned :category, :categories

  load_and_authorize_resource

  respond_to :html
  respond_to :js, only: :destroy
  respond_to :json, only: [:index, :show]

  def index
    index! do |format|
      format.json{ render json: end_of_association_chain.order('name asc').to_json(only: [:id, :name]) }
    end
  end

  def show
    show! do |format|
      format.html {
        @q = resource.products.ransack(params[:q])
        @q.sorts = 'name asc' if @q.sorts.empty?
        @products = @q.result.page(params[:page]).per(Figaro.env.default_pagination.to_i)
      }
      format.json {
        list_of_products = if params[:type] == 'rental'
                             resource.rental_products.select{ |pr| pr.number_of_available > 0 }
                           else
                             resource.products
                           end.sort{ |a,b| a.name.downcase <=> b.name.downcase }
        render json: list_of_products.to_json(only: [:id, :name])
      }
    end
  end

  protected
  def begin_of_association_chain
    current_store
  end

  def collection
    @q = end_of_association_chain.ransack(params[:q])
    @q.sorts = 'name asc' if @q.sorts.empty?
    @categories = @q.result.page(params[:page]).per(Figaro.env.default_pagination)
  end
end
