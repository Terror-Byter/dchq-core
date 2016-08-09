ActiveAdmin.register Company do
  menu parent: "Company"

  actions :all, except: [:create, :new]
  filter :name, :as => :string

  index do
    column "Company Name", :name
    column :created_at
    column :enabled
    default_actions
  end

  show do
    unless company.logo.blank?
      panel "Logo" do
        attributes_table_for company.logo do
          row(:logo) {|logo| image_tag logo.image(:pdf)}
        end
      end
    end
    attributes_table do
      row :id
      row :name
      row :telephone
      row(:email) {mail_to company.email}
      row :primary_contact
      row(:website_url) {link_to company.website_url, "#{ company.website_url }"}
      row :enabled
      row :api_key
      row :created_at
      row :updated_at
      row :primary_contact
      row :referral_code
      row(:referrer_dive_centre) { link_to company.referrer.name, admin_company_path(company.referrer) if company.referrer }
      row(:invited_dive_centres) { company.invited.map{ |dc| link_to dc.name, admin_company_path(dc) }.join(", ").html_safe }
    end
    unless company.address.blank?
      panel "Address" do
        attributes_table_for company.address do
          row(:addres_1) {|address| address.first}
          row(:addres_2) {|address| address.second}
          row(:city) {|address| address.city}
          row(:state) {|address| address.state}
          row(:country) {|address| address.country}
          row(:post_code) {|address| address.post_code}
        end
      end
    end
    panel "Staff Members" do
      table_for company.users do |t|
        t.column(:name) {|user| user.full_name}
        t.column(:email) {|user| mail_to user.email}
        t.column(:role) {|user| user.role}
        t.column(:stores_access) {|user| user.stores.map{|u| link_to u.name, admin_store_path(u)}.join(", ").html_safe}
        t.column(:actions) {|user| link_to 'Login as this user', become_admin_index_path(id: user.id), target: "_blank"}
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "General" do
      f.input :primary_contact_id, as: :select, collection: f.object.users.all.map{|u| [u.email, u.id]}
      f.input :name
      f.input :telephone
      f.input :email
      f.input :website_url
    end
    f.buttons
  end
end
