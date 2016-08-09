class OtherEventsController < InheritedResources::Base
  respond_to :html
  respond_to :js, only: [:trip_price]

  actions :all, except: [:show]
  custom_actions collection: [:trip_price], resource: [:duplicate]

  before_filter :can_be_deleted?, only: :destroy

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

  def trip_price
    render json: EventTrip.find_by_id(params[:id])
  end

  def duplicate
    other_event = resource.deep_clone include: [ { event_customer_participants: [ :event_customer_participant_kit_hire,
                                                                                  :event_customer_participant_insurance,
                                                                                  :event_customer_participant_additionals,
                                                                                  :event_customer_participant_transports ] },
                                                   :event_user_participants],
                                      except: [ :starts_at,
                                                :ends_at,
                                                { event_customer_participants: [:sale_id, :original_id, :parent_id, :reject] } ]

    other_event.starts_at = params[:starts_at]
    other_event.ends_at   = params[:ends_at]
    if other_event.save
      redirect_to event_path(other_event), notice: I18n.t('controllers.other_events.cloned')
    else
      redirect_to event_path(resource), alert: other_event.errors.full_messages
    end
  end

  protected
  def build_resource
    super.tap do |attr|
      attr.store_id = current_store.id
    end
  end

  def can_be_deleted?
    redirect_to event_path(resource), alert: I18n.t("controllers.events.cant_remove_event") unless resource.can_be_deleted?
  end
end
