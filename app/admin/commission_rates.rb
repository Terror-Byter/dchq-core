ActiveAdmin.register CommissionRate do
  menu parent: "Store"
  filter :id, :as => :string
  index do
    column :id
    column "Amount" do |commission_rate|
      number_to_currency commission_rate.amount
    end
    column "Store" do |commission_rate|
      commission_rate.store.name
    end
    default_actions
  end

end
