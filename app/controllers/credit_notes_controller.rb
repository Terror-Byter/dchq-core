class CreditNotesController < InheritedResources::Base
  decorates_assigned :credit_note, :credit_notes
  load_and_authorize_resource

  respond_to :html
  actions :index

  protected
  def begin_of_association_chain
    current_store
  end

  def collection
    @credit_notes = end_of_association_chain.page(params[:page]).per(Figaro.env.default_pagination.to_i)
  end
end
