require 'acceptance/acceptance_spec_helper'

feature 'Sign Up', vcr: true do
  before {
    create(:currency)
  }

  scenario 'User should be able create ne account' do
    visit new_user_registration_path
    expect(page).to have_content I18n.t('registrations.new.store_and_manager')
    expect(page).to have_content I18n.t('registrations.new.p')

    fill_in 'company_name', with: Faker::Company.name
    fill_in 'company_email', with: 'divecentrehq@oceanshq.com'
    fill_in 'company_telephone', with: '1234556789'
    fill_in 'company_address_attributes_first', with: Faker::Address.street_address
    fill_in 'company_address_attributes_second', with: ''
    fill_in 'company_address_attributes_city', with: Faker::Address.city
    fill_in 'company_address_attributes_state', with: Faker::Address.state
    fill_in 'company_address_attributes_post_code', with: '123456'
    fill_in 'company_users_attributes_0_given_name', with: Faker::Name.first_name
    fill_in 'company_users_attributes_0_family_name', with: Faker::Name.last_name
    fill_in 'company_users_attributes_0_email', with: 'divecentrehq@oceanshq.com'
    fill_in 'company_users_attributes_0_password', with: 'password'
    fill_in 'company_users_attributes_0_password_confirmation', with: 'password'

    click_button I18n.t('registrations.new.button')
    expect(page).to have_content I18n.t('registrations.step_2.p')
    click_button I18n.t('registrations.step_2.next')
    click_link I18n.t('registrations.step_3.add_event_setting')

    expect(page).to have_content I18n.t('settings.events.settings_events')
    visit root_path
    expect(page).to have_content I18n.t('pages.index.dashboard')
  end
end
