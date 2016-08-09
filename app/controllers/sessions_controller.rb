class SessionsController < Devise::SessionsController
  layout 'session'
  before_filter :remove_empty_sales, only: [:destroy]

  protected
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || (resource.is_a?(User) && !resource.finished?) ? edit_user_registration_path : signed_in_root_path(resource)
  end

  def remove_empty_sales
    return unless current_user
    User.find(current_user.id).sales.empty.destroy_all
  end
end
