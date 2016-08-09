ActiveAdmin.register Store do
  menu parent: "Company"
  filter :name, :as => :string
  index do
    column :id
    column :name
    column :company
    column :location
    column :currency
    column :created_at
    default_actions
  end
end
