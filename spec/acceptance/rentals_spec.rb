require 'acceptance/acceptance_spec_helper'

feature 'Rental' do
  let(:user){ create(:user) }
  let(:company){ user.company }
  let(:store){ company.stores.first }
  let(:empty_rental){ create(:empty_rental, user: user, store: store) }

  background {
    sign_in user
    visit rentals_path
  }

  scenario 'Manager will be able create new rental', js: true do
    expect(page).to have_content I18n.t('rentals.index.rentals')
    expect(page).to have_content I18n.t('rentals.index.create_rental')

    click_link I18n.t('rentals.index.create_rental')

    expect(page).to have_content I18n.t('overlays.rentals.new.p')
    fill_in 'rental_pickup_date', with: "01/01/2014"
    fill_in 'rental_return_date', with: "02/02/2014"

    click_button I18n.t('overlays.rentals.new.create_rental')

    expect(page).to have_content I18n.t('rentals.edit.new_edit')
    expect(page).to have_content 'New'
    expect(Rental.count).to_not be_zero
  end

  scenario 'Application should ask agreements for create new rental. If customer not accept we rental new shold not show', js: true do
    store.update_attribute :standart_rental_term, Faker::Lorem.paragraph

    visit rentals_path
    expect(page).to have_content I18n.t('rentals.index.rentals')
    expect(page).to have_content I18n.t('rentals.index.create_rental')

    click_link I18n.t('rentals.index.create_rental')
    expect(page).to have_content I18n.t('overlays.rentals.agreement.header')
    click_button I18n.t('overlays.rentals.agreement.customer_decline')
    expect(page).to_not have_content I18n.t('overlays.rentals.agreement.header')
    expect(page).to_not have_content I18n.t('overlays.rentals.new.p')
  end

  scenario 'Manager should be able create rental after accept customer agreements', js: true do
    store.update_attribute :standart_rental_term, Faker::Lorem.paragraph

    visit rentals_path
    expect(page).to have_content I18n.t('rentals.index.rentals')
    expect(page).to have_content I18n.t('rentals.index.create_rental')

    click_link I18n.t('rentals.index.create_rental')
    expect(page).to have_content I18n.t('overlays.rentals.agreement.header')
    click_link I18n.t('overlays.rentals.agreement.customer_acceped')
    expect(page).to have_content I18n.t('overlays.rentals.new.p')
    fill_in 'rental_pickup_date', with: "01/01/2014"
    fill_in 'rental_return_date', with: "02/02/2014"

    click_button I18n.t('overlays.rentals.new.create_rental')

    expect(page).to have_content I18n.t('rentals.edit.new_edit')
    expect(page).to have_content 'New'
    expect(Rental.count).to_not be_zero
  end

  scenario 'Manager will not be able create new rental with errors', js: true do
    expect(page).to have_content I18n.t('rentals.index.rentals')
    expect(page).to have_content I18n.t('rentals.index.create_rental')

    click_link I18n.t('rentals.index.create_rental')
    expect(page).to have_content I18n.t('overlays.rentals.new.p')
    click_button I18n.t('overlays.rentals.new.create_rental')

    expect(page).to have_content 'Pickup date -'
    expect(page).to have_content 'Return date -'

    click_button I18n.t('overlays.rentals.new.cancel')

    click_link I18n.t('rentals.index.create_rental')

    expect(page).to_not have_content 'Pickup date -'
    expect(page).to_not have_content 'Return date -'
  end

  scenario 'Manager should be redirect to edit rental page for layby rental' do
    empty_rental

    visit rentals_path
    expect(page).to_not have_content I18n.t('rentals.index.no_rentals')

    click_link empty_rental.id

    expect(page).to have_content I18n.t('rentals.edit.new_edit')
    expect(page).to have_content 'New'
  end

  scenario 'Manager should be able delete rental' do
    empty_rental
    visit rentals_path
    expect(page).to_not have_content I18n.t('rentals.index.no_rentals')

    click_link empty_rental.id
    click_link I18n.t('rentals.shoping_cart.delete_rental')
    expect(page).to have_content I18n.t('rentals.index.no_rentals')
  end

  scenario 'Manager should be able add note to rental', js: true do
    empty_rental
    visit rental_path(empty_rental)

    click_link I18n.t('rentals.shoping_cart.add_note')
    message = Faker::Lorem.paragraph

    fill_in 'rental_note', with: message
    click_button I18n.t('overlays.rentals.note.button')

    expect(page).to_not have_content I18n.t('rentals.shoping_cart.add_note')
    expect(page).to have_content I18n.t('rentals.shoping_cart.rental_note')
    empty_rental.reload
    expect(empty_rental.note).to eq message
  end

  scenario 'Manager should be able edit note', js: true do
    empty_rental.update_attribute :note, 'Super Note'
    visit rental_path(empty_rental)

    click_link I18n.t('rentals.shoping_cart.edit')
    fill_in 'rental_note', with: "1234567890"
    click_button I18n.t('overlays.rentals.note.button')
    expect(page).to_not have_content I18n.t('rentals.shoping_cart.add_note')
    expect(page).to have_content I18n.t('rentals.shoping_cart.rental_note')
    empty_rental.reload
    expect(empty_rental.note).to eq '1234567890'
  end

  scenario 'Manager can remove note', js: true do
    empty_rental.update_attribute :note, 'Super Note'
    visit rental_path(empty_rental)

    click_link I18n.t('rentals.shoping_cart.edit')
    fill_in 'rental_note', with: ""
    click_button I18n.t('overlays.rentals.note.button')
    expect(page).to have_content I18n.t('rentals.shoping_cart.add_note')
    expect(page).to_not have_content I18n.t('rentals.shoping_cart.rental_note')
    empty_rental.reload
    expect(empty_rental.note).to be_blank
  end
end
