ActiveAdmin.register Currency do
  menu parent: 'Admin'
  filter :name, :as => :string
  filter :unit, :as => :string
  filter :code, :as => :string
end
