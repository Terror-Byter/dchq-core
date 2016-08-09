class PagesController < InheritedResources::Base

  skip_filter :check_available_shops, :set_timezone, only: [:no_access]

  respond_to :html, :js
  actions :index
  custom_actions collection: [:change_current_store, :delete_image, :mail, :no_access,
                              :search, :complete_setup]

  def complete_setup
    current_user.to_finished!
    flash[:notice] = 'Registration completed successfully!'
    redirect_to root_path and return unless params[:to_event]
    redirect_to events_settings_path
  end

  def index
    gon.staff_targets = current_store.generate_sale_targets_for_chart
    gon.currency_unit = gon.currency
    gon.line_chart    = current_store.line_chart
  end

  def email
    render layout: false
  end

  def change_current_store
    if available_stores.find_by_id(params[:id])
      session[:current_store_id] = params[:id]
      flash[:notice] = I18n.t("controllers.store_changed")
    else
      flash[:error] = I18n.t("controllers.no_access")
    end
    redirect_to root_path
  end

  def delete_image
    if record = params[:object].constantize.find_by_id(params[:id])
      record.send(params[:image_type]).destroy
      record.send("build_#{params[:image_type]}")
      record.save
      flash[:notice] = I18n.t("controllers.image_deleted")
    else
      flash[:error] = I18n.t("controllers.image_not_deleted")
    end
    redirect_to :back
  end

  def search
    query = params[:data].nil? ? '' : params[:data].gsub('/', '')
    render json: current_company.search_people(query) + current_store.search_events(query)
  end

end
