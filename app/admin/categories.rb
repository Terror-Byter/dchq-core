ActiveAdmin.register Category do
  menu parent: "Point Of Sale"
  filter :name, :as => :string
  index do
    column :id
    column :name
    column :description
    column "Store", :store_ do |category|
      category.store.name
    end
    column :created_at
    default_actions
  end

  form html: { multipart: true } do |f|
    f.inputs "Category Details" do
      f.input :store_id, as: :select, collection: Store.all
      f.input :name
      f.input :description, as: :text
    end
    f.buttons
  end

end
