class IncidentsController < InheritedResources::Base
  respond_to :html
  respond_to :js, only: :destroy
  respond_to :json, only: :update
  actions :create, :update, :destroy

  belongs_to :customer

  def create
    create! do |success, failure|
      success.html { redirect_to customer_path(resource.customer) }
      failure.html do
        flash.now[:alert] = resource.errors.full_messages.join(", ")
        render template: "customers/show"
      end
    end
  end

  protected
  def build_resource
    super.tap do |attr|
      attr.creator = current_user
    end
  end
end
