class AdminController < ApplicationController

  skip_filter :authenticate_user!

  def become
    redirect_to root_url and return unless current_admin_user
    sign_in(:user, User.find(params[:id]))
    redirect_to root_url # or user_root_url
  end

end
