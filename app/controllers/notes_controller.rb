class NotesController < InheritedResources::Base
  load_and_authorize_resource

  respond_to :html
  respond_to :js, only: :destroy
  respond_to :json, only: :update
  actions :create, :update, :destroy

  belongs_to :customer, :supplier, :business_contact, :membership, :user, :service,  polymorphic: true, optional: true

  def create
    create! do |success, failure|
      success.html { redirect_to :back }
      failure.html { render template: "#{parent_type.to_s.pluralize}/show" }
    end
  end

  protected
  def build_resource
    super.tap do |attr|
      attr.creator = current_user
    end
  end
end
