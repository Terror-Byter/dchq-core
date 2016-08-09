ActiveAdmin.register Sale do
  menu parent: "Point Of Sale"
  filter :store, :as => :string
  index do
    column :id
    column :creator
    column :store
    column :created_at
    column :grand_total
    column :status
    default_actions
  end
end
