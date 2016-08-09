require 'acceptance/acceptance_spec_helper'

feature 'User should be able create BusinessContact' do
  let(:user){ create(:user) }
  let(:company){ user.company }
  let(:supplier){ create(:supplier, company: company) }


  background {
    sign_in user
  }

  scenario 'User should be able create business contact' do
    visit supplier_path(supplier)

    expect(page).to have_content supplier.name
    click_link I18n.t('suppliers.show.new_supplier_contact')
    expect(page).to have_content I18n.t('business_contacts.new.create_supplier_contact')
    expect(page).to have_content I18n.t('business_contacts.form.individual_details')

    fill_in 'business_contact_given_name', with: Faker::Name.first_name
    fill_in 'business_contact_family_name', with: Faker::Name.last_name
    fill_in 'business_contact_email', with: 'test@mail.ru'
    fill_in 'business_contact_telephone', with: '1234567777'
    click_button I18n.t('business_contacts.form.save')

    expect(page).to have_content 'Supplier was successfully created.'
  end
end
