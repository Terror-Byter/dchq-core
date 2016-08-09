class SmartListsController < InheritedResources::Base
  load_and_authorize_resource

  respond_to :html, except: [ :get_values ]
  respond_to :json, only: [ :get_values ]
  actions :all
  custom_actions resource: [:send_email, :export], collection: [:get_values]

  def show
    show! do
      @customers = Kaminari.paginate_array(CustomerSmartList.new(current_company, resource).process).page(params[:page]).per(Figaro.env.default_pagination.to_i)
    end
  end

  def send_email
    customers = CustomerSmartList.new(current_company, resource).process.map(&:email)
    SmartListMailer.delay.send_email(current_company, customers, params[:subject], params[:content])
    redirect_to resource_path, notice: I18n.t('controllers.smart_lists.sent_email')
  end

  def export
    Delayed::Job.enqueue DelayedJob::Export::Customer.new(current_store, current_user, CustomerSmartList.new(current_company, resource).process.to_a)
    redirect_to resource, notice: I18n.t('controllers.export_flash', type: I18n.t('activerecord.models.smart_list.one'))
  end

  def get_values
    list = case params[:type]
           when 'product_purchased', 'product_not_purchased' then current_store.products
           when 'event_completed', 'event_not_completed'then current_store.other_events
           when 'course_completed', 'course_not_completed' then
             CertificationLevel.where( store_id: [nil, 0, current_store.id]).search(params[:q])
           when 'rental_completed' then current_store.rental_products
           when 'servicing_completed' then current_store.type_of_services
           end

    list = if params[:init_id]
             if params[:type] == 'course_completed' || params[:type] == 'course_not_completed'
               elem = CertificationLevel.where( store_id: [nil, 0, current_store.id]).find(params[:init_id])
               { id: elem.id, text: elem.full_name }
             else
               elem = list.find(params[:init_id])
               { id: elem.id, text: elem.label }
             end
           else
             if params[:type] == 'course_completed' || params[:type] == 'course_not_completed'
               list.map{ |p| [id: p.id, text: p.full_name] }.flatten
             else
               list.search(params[:q]).map{ |p| [id: p.id, text: p.label] }.flatten
             end
           end
    render json: list
  end

  protected
  def begin_of_association_chain
    current_company
  end

  def collection
    @smart_lists = end_of_association_chain.page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end

  def build_resource
    super.tap do |attr|
      attr.company = current_company
    end
  end
end
