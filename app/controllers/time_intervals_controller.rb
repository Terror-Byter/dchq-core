class TimeIntervalsController < InheritedResources::Base
  respond_to :js

  load_and_authorize_resource class: Services::TimeInterval

  belongs_to :service

  defaults resource_class: Services::TimeInterval
  actions :create
  custom_actions collection: [:stop]

  def create
    resource[:starts_at] = Time.now
    create! do |success, failure|
      render nothing: true and return
    end
  end

  def stop
    params[:time_interval] = {ends_at: Time.now}
    @time_interval = parent.time_intervals.last
    if @time_interval
      @time_interval.update_attributes(params[:time_interval])
    end
    render template: "time_intervals/stop"
  end

  protected
  def build_resource
    super.tap do |attr|
      attr.user_id = current_user.id
    end
  end
end
