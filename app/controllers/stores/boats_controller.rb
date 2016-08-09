class Stores::BoatsController < InheritedResources::Base
  respond_to :json
  actions :update

  def update
    update! do |success, failure|
      success.json
      failure.json
    end
  end
end
