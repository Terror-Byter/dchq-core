class BusinessContactsController < InheritedResources::Base
  decorates_assigned :business_contact, :business_contacts
  respond_to :html
  respond_to :js, only: :destroy
  respond_to :json, only: :update

  belongs_to :supplier, optional: true

  actions :all, except: [:index]

  def update
    params[:business_contact].delete(:avatar_attributes) if params[:business_contact][:avatar_attributes] and params[:business_contact][:avatar_attributes]['image'].blank?
    super
  end

  protected
  def build_resource
    super.tap do |attr|
      attr.build_avatar unless attr.avatar
    end
  end
end
