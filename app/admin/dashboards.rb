ActiveAdmin.register_page 'Dashboard' do

  content do
    columns do
      column do
        panel "Recent Accounts", priority: 1 do
          table do
            tr do
              th "company"
              th "manager"
              th "manager email"
              th "phone"
              th "signup step"
            end
            Company.includes([:owner, :address]).collect do |company|
              tr do
                td link_to company.name, admin_company_path(company)
                td company.owner.full_name
                td company.owner.email
                td company.telephone
                td company.owner.current_step
              end
            end
          end
        end
      end
    end
  end
end
