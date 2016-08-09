ActiveAdmin.register CertificationAgency do
  menu parent: 'Admin'
  filter :name, :as => :string
  index do
    column :id
    column :name
    column "Number of Certification Levels" do |certification_agency|
      certification_agency.certification_levels.count
    end
    column "Logo", :logo do |certification_agency|
      image_tag certification_agency.logo.image(:thumb) unless certification_agency.logo.blank?
    end
    column :created_at
    default_actions
  end

  form html: { multipart: true } do |f|
    f.object.build_logo if f.object.logo.blank? and !f.object.new_record?
    f.inputs "General" do
      f.input :name
    end

    f.inputs 'Logo' do
      f.semantic_fields_for :logo do |r|
        r.inputs :image, as: :file
        r.inputs :imageable_type, as: :hidden, value: "CertificationAgency"
      end
    end
    f.buttons
  end


end
