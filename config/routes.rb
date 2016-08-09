DchqCore::Application.routes.draw do

  apipie

  root to: 'pages#index'

  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  resources :admin, only: [] do
    collection do
      get :become
    end
  end

  devise_for :users, controllers: { sessions: "sessions", registrations: "registrations", passwords: "passwords" }
  devise_scope :users do
    match 'sign_out' => 'sessions#destroy', via: :get
  end

  resources :stores, only: :update do
    get :set_current, on: :member
    collection do
      get :close
      post :cash_put_out
      get :reopen
    end
  end

  ################################# CUSTOMERS ################################
  resources :customers do
    resources :incidents, only: [:create, :update, :destroy]
    resources :notes, only: [:create]

    collection do
      get :sync_with_mailchimp
      post :export
      post :export_to_qif
      get :mobile_menu
      post :search
      post :update_certification_level_membership
      post :check_certificate
    end

    member do
      get :get_credit_note
      post :add_to_event
      get :check_certification_levels
      get :get_discount_level
      get :recalculate_event_price
      post :get_events
      post :load_sales
      post :load_ecp
    end

    get :update_certification_level_select, on: :collection
  end

  # FIXME: use polymorphic route
  resources :notes, only: [:update, :destroy]

  resources :categories
  resources :brands

  ################################# PRODUCTS ################################
  resources :products do
    collection do
      post :create_extra_option
      post :export
      post :barcode_export
    end
    member do
      post :print_barcode
      get :archived
      get :unarchived
    end
  end

  ################################# SALES ################################
  resources :sales do
    get :history, on: :collection
    get :event_tariffs, on: :collection
    post :pay_for_event, on: :collection
    post :update_extra_options, on: :collection

    collection do
      post :send_receipt_via_email
      get :close
      post :export_to_csv
    end

    member do
      post :add_events
      post :reopen_layby
      post :refund
      get :mark_as_complete
      post :add_product
      post :add_customer
      get  :products_list
      get  :customers_list
      delete :empty
      get :show_email_receipt_form
      get :add_customer_form
      get :add_product_form
      get :search_product
      post :add_note
      post :add_misc_product
    end
  end
  resources :purchase_orders do
    member do
      get :suppliers_list
      post :assign_supplier
      post :remove_supplier
      post :add_product
      get :products_list
      post :empty
      post :add_note
      get :download
      post :set_status
      get :update_order_form_after_send
      post :send_email_to_supplier
      put :set_expected_delivery
      put :update_amend
    end
  end
  resources :payments, only: [:update, :destroy]
  resources :sale_customers, only: [:destroy] do
    put :ignore_events, on: :member
  end

  resources :business_contacts, only: [] do
    resources :notes, only: [:create]
  end

  resources :suppliers do
    resources :notes, only: [:create]
    resources :business_contacts, except: [:index], :path => "/contacts"
    collection do
      get :sync_with_mailchimp
      post :export
    end
  end

  resources :settings, only: [:index, :edit, :update] do
    collection do
      [:user_profile, :stores, :sales, :events, :integrations, :billing, :select_agency, :edit_agency, :trips, :additionals, :edit_mailchimp_step_1,
       :edit_mailchimp_step_2, :print, :import_to_csv_step_1, :switch_store, :servicing, :boats, :emails, :email_example, :clear_data_page,
       :rentals, :restore_sale].each do |route|
        get route
      end
      [:update_stores, :update_store, :update_events, :update_integrations, :update_billing, :update_agency, :update_user].each do |route|
        put route
      end
      [:import_to_csv_step_2, :import, :clear_data].each do |route|
        post route
      end
    end
  end

  namespace :settings do
    resource :xero, only: [:update], controller: "xero" do
      collection do
        get :edit_xero
        get :connect_to_xero
        get :callback
        get :disconnect
        put :update_settings
        post :check_xero_tax_rates
        get :sync
      end
    end
    resource :scubatribe, only: [:create, :new] do
      collection do
        post :signup
      end
    end
  end

  resources :billings, only: [] do
    collection do
      post :stripe_callback
    end
  end

  resources :course_events, except: [:show], :path => "/events/courses" do
    collection do
      get :course_price
    end
    member do
      get :print_event_pickup,    to: 'events#print_event_pickup'
      get :print_event_manifest,  to: 'events#print_event_manifest'
    end
  end
  resources :other_events, except: [:show], :path => "/events/standard" do
    collection do
      get :trip_price
    end
    member do
      get :print_event_pickup,    to: 'events#print_event_pickup'
      get :print_event_manifest,  to: 'events#print_event_manifest'
      post :duplicate
    end
  end

  resources :events, only: [:index, :show, :update] do
    collection do
      get :get_events
      get :get_public_events
      get :list
      get :widget
      post :search
      post :print_resource_manifest
      post :print_staff_roster
      post :print_resource_utilisation
    end
    member do
      get :check_free_sets
      get :cancel_confirmation_no_registrations
      post :cancel
      get :cancel_confirmation_with_registrations
      get :cancel_complete
      get :print_event_pickup
      get :print_resource_manifest
      get :event_user_participants
    end
    resources :event_customer_participants do
      member do
        get :approve
        get :reject_form
        post :reject
        get :reject_paid_form
        post :reject_paid
      end
    end
  end
  resources :event_customer_participants, only: [] do
    delete :remove_from_sale, on: :member
    post :calculate_price, on: :collection
  end

  resources :staff_members do
    collection do
      get :sync_with_mailchimp
      post :export
      get :schedule
    end
    member do
      get :mark_as_day_off
      get :mark_as_available
    end
  end

  resources :users do
    resources :notes, only: [:create]
  end

  ############################################ REPORTS ##############################################
  resources :reports, only: [:index] do
    collection do
      get :sales_by_day
      get :sales_by_month
      get :sales_by_year
      get :sales_by_staff
      get :sales_by_brand
      get :sales_by_category
      get :sales_by_popular
      get :event_sales
      get :financial_reports
      get :edit_finance_report
      put :update_finance_report
    end
  end

  ############################################ BOOKING ##############################################
  resources :bookings, only: [] do
    collection do
      get :step_1
      post :step_2
      post :create_customer
      post :calculate_price
      get :cancel
      get :paypal_complete
    end
  end

  ################################# CUSTOMERS ################################
  resources :gift_card_types do
    member do
      get :pause
      get :resume
    end
  end

  resources :gift_cards, only: [:show, :update]

  resources :credit_notes, only: [:index]
  resources :services do
    collection do
      get :get_type_of_service
      get :add_item
    end
    member do
      post :complete
    end
    resources :service_notes, only: [:edit, :update, :destroy]
    resources :time_intervals, only: [:create] do
      collection do
        post :stop
      end
    end
  end

  resources :certification_levels, only: [:update]
  resources :event_trips, only: [:update]

  namespace :stores do
    resources :boats, only: [:update]
  end

  #RENTAL MODULE
  resources :rentals, except: [:new] do
    member do
      post :add_rental_product
      delete :remove_payment
      post :send_receipt_via_email
    end
  end

  ############################################ RENTAL PRODUCTS ##################################
  resources :rental_products do
    collection do
      get :search
      post :export
    end

    member do
      get :archived
      get :unarchived
    end
  end

  ############################################ SMART LISTS ##################################
  resources :smart_lists do
    member do
      post :send_email
      post :export
    end
    collection do
      get :get_values
    end
  end

  ############################################ REVIEWS / ScubaTribe #############################
  resources :reviews, only: [:index]
  resources :requests, only: [:index]

  ############################################ API ##############################################
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      devise_scope :user do
        post 'sessions' => 'sessions#create', :as => 'login'
      end
      resources :companies, only: [:create]
      resources :currencies, only: [:index]
      resources :customers, only: [:index, :show, :create, :update, :destroy]
      resources :events, only: [:index, :show, :create, :update, :destroy] do
        resources :event_user_participants, only: [:update, :create, :destroy]
        resources :event_customer_participants, only: [:update, :create, :destroy]
      end
      [:boats, :stores, :pages, :tax_rates].each do |res|
        resources res, only: [:index]
      end
      resources :categories, only: [:index, :show]
      resources :brands, only: [:index, :show]
      resources :event_trips, only: [:index, :show]
      resources :certification_agencies, only: [:index, :show]
      resources :users, only: [:index] do
        get :info, on: :collection
      end
      resources :sales, only: [:index, :show, :new] do
        collection do
          get :products
          post :remove_customer
        end
        member do
          post :add_customer
          post :add_product
          post :send_receipt
          post :add_misc_product
        end
      end
      resources :reports, only: [] do
        collection do
          [:sales_by_brand, :sales_by_category, :sales_by_day, :sales_by_products, :sales_by_staff_member,
           :financial_reports].each do |route|
            get route
          end
          match '/financial_reports/:id' => 'reports#financial_report_details', via: :get
          match '/financial_reports/:id' => 'reports#update_finance_report', via: :put
        end
      end
      resources :products, except: [:new, :edit]
    end
  end

  resources :pages, only: [] do
    collection do
      %w(change_current_store delete_image no_access search complete_setup).each do |route|
        get route.to_sym
      end
      %w[send_message send_support_request].each do |route|
        post route.to_sym
      end
    end
  end
end
