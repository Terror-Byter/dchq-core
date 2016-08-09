ActiveAdmin.register Customer do
  menu parent: "Company"
  filter :name, as: :string
end
