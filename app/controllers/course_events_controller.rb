class CourseEventsController < InheritedResources::Base
  respond_to :html
  respond_to :js, only: [:course_price]
  actions :all, except: [:show]
  custom_actions collection: [:course_price]

  before_filter :redirect_to_parent, only: [:destroy, :edit]

  def index
    redirect_to events_path
  end

  def create
    create! do |success, failure|
      success.html { redirect_to event_path(resource) }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to event_path(resource) }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to events_path }
    end
  end

  def course_price
    render json: CertificationLevel.find(params[:id]).cost
  end

  protected
  def begin_of_association_chain
    current_store
  end

  def build_resource
    super.tap do |attr|
      attr.store_id = current_store.id
      attr.frequency    = 0
      attr.event_type_id   = EventType.find_by_name('Course').id
    end
  end

  def redirect_to_parent
    @course_event = resource.parent unless resource.parent?
  end
end
