require 'acceptance/acceptance_spec_helper'

feature 'Rental Product' do
  let(:user){ create(:user) }
  let(:company){ user.company }
  let(:store){ company.stores.first }
  let(:category){ create(:category, store: store) }
  let(:supplier){ create(:supplier, company: company) }
  let(:brand){ create(:brand, store: store) }
  let(:rental_product){ create(:rental_product, store: store, supplier: supplier, brand: brand, category: category) }

  background {
    brand
    category
    supplier
    sign_in user
    visit rental_products_path
  }

  scenario 'Manager will be able create Rental Product', js: true do
    expect(page).to have_content I18n.t('rental_products.index.no_available')
    expect(page).to have_content I18n.t('rental_products.index.rental_inventory')

    click_link I18n.t('rental_products.index.new_inventory')
    expect(page).to have_content I18n.t('rental_products.new.new')

    product_name = Faker::Company.name
    fill_in 'rental_product_name', with: product_name
    fill_in 'rental_product_sku_code', with: rand(99999999)
    fill_in 'rental_product_number_in_stock', with: rand(99)
    fill_in 'rental_product_description', with: Faker::Lorem.paragraph

    click_link I18n.t('rental_products.form.photos')
    expect(page).to have_content I18n.t('application.attachment_fields.upload_file')
    attach_file 'rental_product_logo_attributes_image', File.join(Rails.root, '/spec/fixtures/image.png'), visible: false

    click_link I18n.t('rental_products.form.accounting_and_barcode')
    expect(page).to have_content I18n.t('store_products.accounting_and_barcode.account_codes')

    fill_in 'rental_product_accounting_code', with: rand(98765)
    fill_in 'rental_product_supplier_code', with: rand(98765)
    fill_in 'rental_product_barcode', with: rand(98765)

    click_link I18n.t('rental_products.form.pricing')
    expect(page).to have_content I18n.t('store_products.tax_and_commission.tax_commissions')

    fill_in 'rental_product_price_per_day', with: 200
    click_button I18n.t('rental_products.form.save')

    expect(page).to have_content I18n.t('rental_products.show.rental_product')
    expect(page).to have_content product_name
  end

  scenario 'Manager should not be able create Rental Product with empty fields' do
    expect(page).to have_content I18n.t('rental_products.index.no_available')
    expect(page).to have_content I18n.t('rental_products.index.rental_inventory')

    click_link I18n.t('rental_products.index.new_inventory')
    expect(page).to have_content I18n.t('rental_products.new.new')
    click_button I18n.t('rental_products.form.save')

    expect(page).to have_content "Name can't be blank"
    expect(page).to have_content "SKU can't be blank"
    expect(page).to have_content "Price per day can't be blank"
    expect(page).to have_content "Price per day is not a number"
  end

  scenario 'Manager should be able remove rental products', js: true do
    rental_product
    visit rental_products_path

    expect(page).to have_content rental_product.name
    expect(page).to have_content rental_product.sku_code

    click_link rental_product.name
    expect(page).to have_content rental_product.name
    click_link I18n.t('rental_products.show.delete_btn')
    page.driver.browser.switch_to.alert.accept

    expect(page).to_not have_content rental_product.name
    expect(RentalProduct.count).to be_zero
  end

  scenario 'Manager should be able edit rental products' do
    rental_product
    visit rental_products_path

    expect(page).to have_content rental_product.name
    expect(page).to have_content rental_product.sku_code

    click_link rental_product.name
    expect(page).to have_content rental_product.name
    click_link I18n.t('rental_products.show.edit')

    product_name = Faker::Company.name
    fill_in 'rental_product_name', with: product_name

    click_button I18n.t('rental_products.form.save')

    expect(page).to have_content I18n.t('rental_products.show.rental_product')
    expect(page).to have_content product_name
  end

  scenario 'Manager should be able archived / unarchived rental products' do
    rental_product
    visit rental_products_path

    expect(page).to have_content rental_product.name
    expect(page).to have_content rental_product.sku_code

    click_link rental_product.name
    expect(page).to have_content rental_product.name

    click_link I18n.t('rental_products.show.archived')
    expect(page).to have_content I18n.t('controllers.rental_products.archived')
    rental_product.reload
    expect(rental_product.archived).to be_truthy

    click_link I18n.t('rental_products.show.unarchived')
    expect(page).to have_content I18n.t('controllers.rental_products.unarchived')
    rental_product.reload
    expect(rental_product.archived).to be_falsey
  end

  scenario 'Manager will be able select between archived/unarchived view' do
    rental_product
    visit rental_products_path

    expect(page).to have_content rental_product.name
    expect(page).to have_content rental_product.sku_code

    click_link I18n.t('rental_products.index.archived_rental_inventory')
    expect(page).to_not have_content rental_product.name
    expect(page).to_not have_content rental_product.sku_code

    rental_product.archived!
    visit rental_products_path

    expect(page).to_not have_content rental_product.name
    expect(page).to_not have_content rental_product.sku_code
    click_link I18n.t('rental_products.index.archived_rental_inventory')
    expect(page).to have_content rental_product.name
    expect(page).to have_content rental_product.sku_code
  end
end
