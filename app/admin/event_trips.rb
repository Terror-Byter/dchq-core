ActiveAdmin.register EventTrip do
  menu parent: "Store"
  filter :name, :as => :string
  index do
    column :id
    column :name
    column :cost
    column :commission_rate_money
    column :store
    column "Tax Rate" do |event_trip|
      event_trip.tax_rate.amount
    end
    column "Commission Rate" do |event_trip|
      event_trip.commission_rate.amount
    end
    column :created_at
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :cost
      row :commission_rate_money
      row :store
      row "Tax Rate" do |event_trip|
        event_trip.tax_rate.amount
      end
      row "Commission Rate" do |event_trip|
        event_trip.commission_rate.amount
      end
      row :created_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :store_id, as: :select, collection: Store.all.collect{|u| [u.name, u.id]}
      f.input :tax_rate_id, as: :select, collection: TaxRate.all.collect{|u| [u.amount, u.id]}
      f.input :commission_rate_id, as: :select, collection: CommissionRate.all.collect{|u| [u.amount, u.id]}
      f.input :name
      f.input :cost
      f.input :commission_rate_money
    end
  end
end
