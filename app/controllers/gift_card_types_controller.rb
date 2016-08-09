class GiftCardTypesController < InheritedResources::Base
  load_and_authorize_resource

  respond_to :html

  custom_actions :member => [:pause, :resume]

  def pause
    resource.update_attributes :can_sold => false
    redirect_to :back, :notice => I18n.t("controllers.disable_sold_gift_cards")
  end

  def resume
    resource.update_attributes :can_sold => true
    redirect_to :back, :notice => I18n.t("controllers.enable_sold_gift_cards")
  end

  protected
  def begin_of_association_chain
    current_company
  end

  def collection
    @gift_card_types = end_of_association_chain.page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end
end
