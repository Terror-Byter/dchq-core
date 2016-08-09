class StoresController < InheritedResources::Base
  decorates_assigned :store, :stores
  respond_to :html
  actions :update
  custom_actions resource: :set_current, collection: [:close, :cash_put_out]

  def set_current
    session[:current_store_id] = params[:id] if available_stores.map(&:id).include?(params[:id].to_i)
    redirect_to root_path
  end

  def update
    update! do |success, failure|
      success.html {
        current_user.jump_to_next_step!
        redirect_to edit_user_registration_path
      }
      failure.html {
        @store = resource
        render template: "registrations/edit"
      }
    end
  end

  def cash_put_out
    flash[:notice] ||= []
    open if current_store.close?

    till_attr = {store_id: current_store.id, user_id: current_user.id}.merge(params[:store][:tills_attributes]["0"])
    current_store.tills.create!(till_attr)
    flash[:notice] << I18n.t("controllers.stores.till_updated_successfully")
    redirect_to sales_path
  end

  def open
    current_store.working_times.create!(open_at: Time.now, opened_user_id: current_user.id, close_at: nil)
    flash[:notice] = I18n.t("controllers.stores.open_successfully")
  end

  def reopen
    current_store.reopen!
    redirect_to sales_path, notice: I18n.t("controllers.stores.open_successfully")
  end

  def close
    if current_store.set_close!
      flash[:notice] = I18n.t("controllers.stores.close_successfully")
      if current_user.manager?
        redirect_to financial_reports_reports_path
      else
        redirect_to root_path
      end
    else
      redirect_to sales_path, alert: 'We can\'t close store. please notify administrator'
    end
  end
end
