class ServiceNotesController < InheritedResources::Base
  decorates_assigned :service, :services

  load_and_authorize_resource class: Services::ServiceNote

  respond_to :html, :js
  defaults resource_class: Services::ServiceNote
  actions :edit, :update, :destroy
  belongs_to :service

  layout 'overlay'
end
