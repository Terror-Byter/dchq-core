ActiveAdmin.register CertificationLevel do
  menu parent: "Store"
  filter :name, :as => :string
  index do
    column :id
    column :name
    column "Certification Agency" do |certification_level|
      certification_level.certification_agency.name
    end
    column "Store" do |certification_level|
      certification_level.store.name if certification_level.store
    end
    default_actions
  end

  show do
   attributes_table do
     row :id
     row :name
     row "Certification Agency" do |certification_level|
       certification_level.certification_agency.name
     end
     row :store
     row :created_at
     row :updated_at
   end
  active_admin_comments
  end
end
