class GiftCardsController < InheritedResources::Base
  respond_to :js

  actions :show, :update

  layout 'overlay', only: :show
end
