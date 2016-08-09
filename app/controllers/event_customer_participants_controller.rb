class EventCustomerParticipantsController < InheritedResources::Base
  decorates_assigned :event_customer_participant, :event_customer_participants
  respond_to :html, :js

  actions :all, except: [:show, :index]
  custom_actions resource: [:remove_from_sale, :approve, :reject, :reject_paid],
                 collection: :calculate_price

  belongs_to :event, optional: true

  before_filter :redirect_to_parent, only: [:new]
  before_filter :check_event_for_cancel, only: [:new, :create, :edit, :update]
  before_filter :define_parent, only: [:create, :calculate_price]

  def create
    if params[:event_customer_participant_id].blank?
      @parent.event_customer_participants.build(params[:event_customer_participant])
    else
      params[:event_customer_participant_id].each do |customer_id|
        params[:event_customer_participant].merge!(customer_id: customer_id)
        @parent.event_customer_participants.build(params[:event_customer_participant])
      end
    end

    if @parent.save
      redirect_to event_path(@parent), notice: I18n.t("controllers.event_customer_participants.all_good")
    else
      redirect_to new_event_event_customer_participant_path(@parent), alert: @parent.errors.full_messages.join(", ")
    end
  end

  def calculate_price
    @ecp_array = []
    unless params[:event_customer_participant_id].blank?
      params[:event_customer_participant_id].each do |customer_id|
        params[:event_customer_participant].merge!(customer_id: customer_id)
        @ecp_array << @parent.event_customer_participants.build(params[:event_customer_participant])
      end
    else
      @ecp_array << @parent.event_customer_participants.build(params[:event_customer_participant])
    end
    render 'event_customer_participants/calculate_price.js'
  end

  def update
    update!{ event_path(parent) }
  end

  def destroy
    destroy!{ event_path(parent) }
  end

  def remove_from_sale
    remove_from_sale! do |format|
      format.js do
        @sale = resource.sale
        render nothing: true and return unless @sale

        resource.update_attributes sale_id: nil
        @sale.update_amounts! false, resource if @sale
      end
    end
  end

  def approve
    resource.approve
    redirect_to root_path, notice: I18n.t("controllers.event_approve")
  end

  def reject
    SaleMailer.delay.send_bookings_email_for_customer_reject(resource, params[:reason])
    resource.destroy
    redirect_to root_path, notice: I18n.t("controllers.customer_has_been_rejected")
  end

  def reject_paid
    @sale = resource.sale
    @refunded_sale = @sale.refund!(ecp_id: resource.id)
    @refunded_sale.payments.build(cashier_id: current_user.id,
                                  payment_method_id: resource.sale.payments.first.payment_method.id,
                                  amount: resource.price
                                 )
    @refunded_sale.save

    if @refunded_sale.refund_charge
      @refunded_sale.update_attributes(status: "complete_refund", parent_id: @sale.id)

      SaleMailer.delay.send_bookings_email_for_customer_reject(resource, params[:reason])

      resource.update_attributes need_show: false, reject: true

      flash[:notice] = I18n.t("controllers.customer_has_been_rejected")
    else
      flash[:error] = @refunded_sale.errors.full_messages.join(", ")
      @refunded_sale.destroy
    end
    redirect_to root_path
  end

  def destroy
    CompanyMailer.delay.event_participant_removed(resource.event, resource.customer) if params[:send_email] && resource.customer && !resource.customer.email.blank?
    if resource.sale && ( resource.sale.layby? || resource.sale.complete? )
      redirect_to edit_sale_path(resource.create_refund_sale_list)
    else
      destroy! { event_path(parent) }

      #TODO discuss this along with ticket #1647

      #if resource.event.course?
      #  event = resource.event.parent? ? resource.event : resource.event.parent
      #  event.children.to_a.push(event).each do |event|
      #    event.event_customer_participants.where(customer_id: resource.customer_id).each(&:destroy)
      #  end
      #else
      #  resource.destroy
      #end
      #redirect_to event_path(parent)
    end
  end

  private
  def check_event_for_cancel
    event = Event.find(params[:event_id])
    redirect_to event_path(event), alert: I18n.t("controllers.event_cancelled") if event.cancel?
  end

  def define_parent
    @parent = current_store.events.find_by_id(params[:event_customer_participant][:event_id])
  end

  def redirect_to_parent
    event = current_store.events.find_by_id(params[:event_id])
    redirect_to new_event_event_customer_participant_path(event.parent) if event.try(:course?) && !event.parent?
  end
end
