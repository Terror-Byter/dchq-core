ActiveAdmin.register AdminUser do
  menu parent: "Admin"
  filter :email, :as => :string
  index do
    column :id
    column :email
    column :current_sign_in_at
    column :current_sign_in_ip
    column :updated_at
    default_actions
  end

  form do |f|
    f.inputs "New Admin User" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.buttons
  end

end
