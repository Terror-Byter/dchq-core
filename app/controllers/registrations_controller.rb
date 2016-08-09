class RegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, only: [ :new, :create ]
  prepend_before_filter :authenticate_scope!, only: [:edit, :update, :destroy]
  skip_filter :check_access, :check_available_shops
  include Devise::Controllers::ScopedViews
  layout 'registration'

  def new
    build_resources
    render :new
  end

  def create
    @company = Company.new(params[:company])

    @company.users.first.build_address
    @company.users.first.build_avatar

    if @company.save
      @company.reload
      @company.owner.to_step_2!

      sign_in(User, @company.owner)
      redirect_to edit_user_registration_path
    else
      build_resources
      render :new
    end
  end

  def edit
    redirect_to root_path and return if current_user.finished?

    build_resources
    render :edit
  end

  def update
    if params[resource_name] && params[resource_name][:from_edit_form]
      if params[resource_name][:password].blank? and params[resource_name][:password_confirmation].blank?
        params[resource_name].delete(:password)
        params[resource_name].delete(:password_confirmation)
      end

      params[:user].delete(:avatar_attributes) if params[:user][:avatar_attributes]['image'].blank?

      if resource.update_attributes(params[resource_name])
        set_flash_message :notice, :updated
        sign_in resource_name, resource, bypass: true
        redirect_to user_profile_settings_path
      else
        clean_up_passwords(resource)
        render template: "settings/user_profile", layout: 'application'
      end
    else
      build_resources

      if @company.update_attributes(params[:company])
        @company.owner.jump_to_next_step!
        redirect_to edit_user_registration_path
      else
        build_resources
        render :edit
      end
    end
  end

  protected
  def build_resources
    @company ||= (current_user && current_user.company) || Company.new

    unless current_user
      @user = @company.owner || @company.users.first || @company.users.build
      @address = @company.address || @company.build_address
      @logo = @company.logo || @company.build_logo
    else
      @store = @company.default_store if current_user.step_2? || current_user.step_3?
      @agencies = CertificationAgency.includes(:logo) if current_user.step_3?
    end
  end

  def authenticate_scope!
    send(:authenticate_user!, force: true)
    self.resource = send(:current_user)
  end
end
