class SaleCustomersController < InheritedResources::Base
  respond_to :js, only: [:destroy, :ignore_events]
  custom_actions resource: :ignore_events

  def ignore_events
    ignore_events! do
      resource.update_attributes(ignore_events: true)
    end
  end

  def destroy
    resource.destroy
    resource.sale.update_amounts!
  end
end
