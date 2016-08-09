class StaffMembersController < InheritedResources::Base
  decorates_assigned :staff_member, :staff_members
  include Mailchimp

  load_and_authorize_resource class: User

  defaults resource_class: User
  respond_to :html, :csv
  custom_actions collection: [:sync_with_mailchimp, :export, :schedule], resource: [:mark_as_available, :mark_as_day_off]
  before_filter :check_able_remove_resource, only: [:destroy]

  def update
    resource_name = "user"
    if params[resource_name][:password].blank? && params[resource_name][:password_confirmation].blank?
      params[resource_name].delete(:password)
      params[resource_name].delete(:password_confirmation)
    end
    params[resource_name].delete(:avatar_attributes) if params[resource_name][:avatar_attributes] && params[resource_name][:avatar_attributes]['image'].blank?
    params[resource_name].delete(:role) unless current_user.manager?
    super{resource_path}
  end

  def sync_with_mailchimp
    collection.each do |record|
      begin
        sync_mailchimp record
      rescue Exception => e
        flash[:error] = I18n.t("controllers.sync_failed", message: e.message, id: record.id)
        break
      end
    end
    flash[:notice] = I18n.t("controllers.staff_sync_ok") if flash[:error].blank?
    redirect_to collection_path
  end

  def export
    Delayed::Job.enqueue DelayedJob::Export::StaffMember.new(current_store, current_user)
    redirect_to collection_path, notice: I18n.t('controllers.export_flash', type: I18n.t('activerecord.models.staff_member.one'))
  end

  def schedule
    @start_date = Date.parse(params[:start_date]) rescue Date.today
    @end_date   = Date.parse(params[:end_date]) rescue Date.today + 13.days
  end

  def mark_as_available
    date = Date.parse(params[:date])
    holiday = resource.user_holidays.where(start_date: date, end_date: date)
    if holiday.any?
      holiday.map(&:destroy)
    else
      resource.overtime << date unless resource.overtime.include?(date)
      resource.save!
    end
    render json: :ok
  end

  def mark_as_day_off
    date = Date.parse(params[:date])
    resource.overtime.delete(date)
    resource.save!
    resource.user_holidays.create!(start_date: date, end_date: date) if resource.user_holidays.where(start_date: date, end_date: date).blank?

    if resource.send(date.strftime('%A').downcase) == '0' && !resource.overtime.include?(date)
      render json: { color: 'orange', title: 'day off' }
    else
      render json: { color: '#DFF233', title: 'holiday' }
    end
  end

  protected
  def begin_of_association_chain
    current_company
  end

  def collection
    @q = end_of_association_chain.ransack(params[:q])
    @staff_members = @q.result.page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end

  def build_resource
    super.tap do |attr|
      attr.build_address unless attr.address
      attr.build_avatar unless attr.avatar
      attr[:current_step] = "finished"
    end
  end

  def check_able_remove_resource
    redirect_to staff_member_path(resource), alert: I18n.t("controllers.you_cant_remove_resource") if !current_user.manager? or !resource.can_be_deleted?
  end
end
