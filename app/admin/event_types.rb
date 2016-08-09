ActiveAdmin.register EventType do
  menu parent: "Admin"
  filter :name, :as => :string
end
