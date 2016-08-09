class CertificationLevelsController < InheritedResources::Base
  respond_to :json
  actions :update

  def update
    update! do |success, failure|
      success.json{ respond_with_bip(resource) }
      failure.json{ respond_with_bip(resource) }
    end
  end
end
