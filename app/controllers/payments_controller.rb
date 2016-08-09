class PaymentsController < InheritedResources::Base
  respond_to :js, :html, only: :destroy
  respond_to :json, :html, only: :update
end
