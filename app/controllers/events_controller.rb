class EventsController < InheritedResources::Base
  decorates_assigned :event, :events
  respond_to :html, :all
  respond_to :js, only: [:list]
  respond_to :json, only: [:get_events, :get_public_events]

  actions :index, :show, :update
  custom_actions collection: [:get_events, :get_public_events, :print_resource_manifest, :print_staff_roster,
                              :print_resource_utilisation, :list],
                 resource: [ :cancel_complete, :cancel, :cancel_confirmation_no_registrations,
                             :cancel_confirmation_with_registrations, :print_event_pickup, :print_event_manifest, :event_user_participants ]

  layout false, only: [:print_resource_manifest, :print_staff_roster, :print_resource_utilisation,
                       :print_event_pickup, :print_event_manifest]

  before_filter :already_canceled?, only: [:cancel_confirmation_no_registrations, :cancel, :cancel_confirmation_with_registrations]
  skip_before_filter :authenticate_user!, only: [:widget, :get_events, :get_public_events, :check_free_sets]

  def index
    gon.CALENDAR_VIEW_TYPE = current_store.calendar_type
    gon.SHOW_DATE = current_store.events.future.any? ? current_store.events.future.first.starts_at.to_date : Date.today
    return unless params[:type]
  end

  def widget
    @store = Store.find_by_public_key(params[:public_key])
    if @store
      gon.PUBLIC_KEY = @store.public_key
      gon.SHOW_DATE = @store.events.visible.future.any? ? @store.events.visible.future.first.starts_at.to_date : Date.today
      render layout: 'widget'
    else
      render text: 'You have no access to this page'
    end
  end

  def list
    gon.CALENDAR_VIEW_TYPE = current_store.calendar_type

    @start_date = DateTime.parse(params[:date]).beginning_of_month.beginning_of_day rescue Date.today.beginning_of_month.beginning_of_day
    @end_date   = @start_date.end_of_month.end_of_day

    @events = list = current_store.events.includes([:boat, :event_type, :parent]).time_period(@start_date, @end_date).order("starts_at ASC")

    if params[:unassigned] or params[:boat_ids]
      @events = []
      @events += list.unassigned if params[:unassigned] == 'true'
      @events += list.for_boat(params[:boat_ids]) if params[:boat_ids]
    end

    @q = @events.ransack(params[:q])
    @events = @q.result
    @events_paginate = @events.page(params[:page]).per(Figaro.env.default_pagination.to_i)

    respond_to do |format|
      format.js
      format.html
    end
  end

  def get_events
    starts = Time.at(params['start'].blank? ? Time.now.to_i : params['start'].to_i)
    ends   = Time.at(params['end'].blank? ? Time.now.to_i : params['end'].to_i)

    @current_store ||= Store.find(session[:current_store_id])
    render text: 'Store is undefined' and return if @current_store.blank?

    Time.zone = @current_store.try(:time_zone)
    events = list = @current_store.events.includes([:boat, :event_type, :parent, :users])
      .where{ (starts_at.gteq starts) & (ends_at.lteq ends) }

    if params[:unassigned] or params[:boat_ids]
      events = []
      events += list.unassigned if params[:unassigned] == 'true'
      events += list.for_boat(params[:boat_ids]) if params[:boat_ids]
    end

    events_list = []
    events.each do |event|
      event = event.decorate
      events_list << {url:         event_path(event),
                      title:       event.name,
                      start:       event.starts_at.iso8601,
                      end:         event.ends_at.iso8601,
                      allDay:      event.all_day,
                      color:       event.boat_color,
                      className:   event.css_class }
    end

    users = @current_store.users.includes(:user_holidays).group(:id)

    if params[:staff] == 'true'
      (starts.to_date..ends.to_date).each do |date|
        events_list << {
          start: date.iso8601,
          end: date.iso8601,
          title: users.select{ |u| u.available_on?(date) }.map(&:full_name).join(', '),
          users: users.select{ |u| u.available_on?(date) }.map { |u| { name: u.full_name, url: staff_member_path(u) } },
          allDay: true,
          color: 'yellow',
          className: 'users' }
      end
    end

    render json: events_list
  end

  def get_public_events
    starts = Time.at(params['start'].blank? ? Time.now.to_i : params['start'].to_i)
    ends   = Time.at(params['end'].blank? ? Time.now.to_i : params['end'].to_i)

    store = Store.find_by_public_key(params[:public_key])
    render text: 'Store is undefined' and return if store.blank?

    Time.zone = store.try(:time_zone)
    events = list = store.events.visible.includes([:boat, :event_type, :parent]).where{ (starts_at.gteq starts) & (ends_at.lteq ends) }

    if params[:unassigned] or params[:boat_ids]
      events = []
      events += list.unassigned if params[:unassigned] == 'true'
      events += list.for_boat(params[:boat_ids]) if params[:boat_ids]
    end

    events_list = []
    events.each do |event|
      event = event.decorate
      events_list << {id:          event.id,
                      title:       event.name,
                      start:       event.starts_at.iso8601,
                      end:         event.ends_at.iso8601,
                      allDay:      false,
                      color:       event.boat_color,
                      className:   event.css_class }
    end

    render json: events_list
  end

  def check_free_sets
    render json: {has_sets: resource.available_places.zero? ? 'no' : 'yes' }
  end

  def cancel
    resource.make_cancel
    resource.notify_customer(current_company.customers.find(params[:customer_id]), params[:email_text]) if params[:customer_id] && params[:email_text]
    if !resource.no_registrations? and !resource.no_payments?
      resource.get_paid_event_customer_participants.each do |ecp|
        sale = ecp.sale
        next unless sale
        ecp.update_attribute :need_show, false
        sale.refund!(ecp_id: ecp.id)
      end
      redirect_to cancel_complete_event_path(resource) and return
    end
    redirect_to event_path(resource), notice: I18n.t("controllers.event_has_been_cancelled")
  end

  def print_resource_manifest
    @boat = current_store.boats.find_by_id(params[:boat_id])
    check_date_in_params

    params[:boat_id] = current_store.boats.map(&:id) + [nil] if params[:boat_id] == 'all'
    params[:boat_id] = nil if params[:boat_id].empty?

    @events = Event.for_boat(params[:boat_id]).where(
      starts_at: Time.parse(params[:starts_at]).in_time_zone(current_store.time_zone).beginning_of_day..Time.parse(params[:ends_at]).in_time_zone(current_store.time_zone).end_of_day
    ).order(:starts_at)
  end

  def print_staff_roster
    check_date_in_params

    @users = current_company.users.where(id: params[:staff_member_id])

    if @users.empty?
      redirect_to collection_path, alert: 'Staff Member cannot be blank'
      return
    end

    @events = Event.includes(:event_user_participants).where(
      starts_at: @starts_at.beginning_of_day..@ends_at.end_of_day,
      store_id: current_store.id,
      event_user_participants: { user_id: @users.map(&:id) }
    ).order(:starts_at).each_with_object(Hash.new { |h, k| h[k] = [] }) do |event, memo|
      event.event_user_participants.each do |eup|
        memo[eup.user_id] << event
      end
    end

  end

  def print_resource_utilisation
    check_date_in_params
  end

  protected
  def check_date_in_params
    @starts_at = Date.parse(params[:starts_at]) rescue Date.today
    @ends_at = Date.parse(params[:ends_at]) rescue Date.today + 7.days
    redirect_to collection_path, alert: I18n.t("controllers.events.incorrect_start_date") and return if @starts_at > @ends_at
  end

  def begin_of_association_chain
    current_store
  end

  def collection
    @events ||= end_of_association_chain.events_time('month').page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end

  def already_canceled?
    event = Event.find(params[:id])
    redirect_to event_path(event), alert: I18n.t("controllers.event_cancelled") if event.cancel?
  end
end
