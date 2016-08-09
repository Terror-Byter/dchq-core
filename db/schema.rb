# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160307120027) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "addresses", :force => true do |t|
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.string   "first"
    t.string   "second"
    t.string   "city"
    t.string   "state"
    t.string   "country_code",     :limit => 2
    t.string   "post_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "addresses", ["addressable_id", "addressable_type"], :name => "index_addresses_on_addressable_id_and_addressable_type"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                                :null => false
    t.string   "encrypted_password",     :limit => 128,                :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "all_payments", :force => true do |t|
    t.integer  "sale_id"
    t.integer  "cashier_id"
    t.integer  "payment_method_id"
    t.decimal  "amount",              :precision => 11, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_transaction"
    t.integer  "customer_id"
    t.string   "type"
    t.integer  "rental_id"
  end

  add_index "all_payments", ["cashier_id"], :name => "index_payments_on_cashier_id"
  add_index "all_payments", ["payment_method_id"], :name => "index_payments_on_payment_method_id"
  add_index "all_payments", ["rental_id"], :name => "index_all_payments_on_rental_id"
  add_index "all_payments", ["sale_id"], :name => "index_payments_on_sale_id"

  create_table "attachments", :force => true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.string   "data_file_size"
    t.datetime "data_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["attachable_id", "attachable_type"], :name => "index_attachments_on_attachable_id_and_attachable_type"

  create_table "boats", :force => true do |t|
    t.integer "store_id"
    t.string  "name"
    t.string  "color"
  end

  add_index "boats", ["store_id"], :name => "index_boats_on_dive_shop_id"

  create_table "brands", :force => true do |t|
    t.integer  "store_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "brands", ["name"], :name => "index_brands_on_name"
  add_index "brands", ["store_id"], :name => "index_brands_on_dive_shop_id"

  create_table "business_contacts", :force => true do |t|
    t.integer  "supplier_id"
    t.string   "given_name"
    t.string   "family_name"
    t.string   "email"
    t.string   "telephone"
    t.string   "position"
    t.boolean  "primary",     :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "business_contacts", ["supplier_id"], :name => "index_business_contacts_on_supplier_id"

  create_table "categories", :force => true do |t|
    t.integer  "store_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], :name => "index_categories_on_name"
  add_index "categories", ["store_id"], :name => "index_categories_on_dive_shop_id"

  create_table "certification_agencies", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "certification_agencies", ["name"], :name => "index_certification_agencies_on_name"

  create_table "certification_level_costs", :force => true do |t|
    t.integer  "certification_level_id"
    t.integer  "tax_rate_id"
    t.decimal  "cost",                   :precision => 11, :scale => 2
    t.integer  "commission_rate_id"
    t.decimal  "commission_rate_money",  :precision => 10, :scale => 0
    t.integer  "store_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "certification_level_costs", ["certification_level_id"], :name => "certification_level_id"
  add_index "certification_level_costs", ["store_id"], :name => "certification_level_dive_shop"

  create_table "certification_level_memberships", :force => true do |t|
    t.integer  "memberable_id"
    t.string   "memberable_type"
    t.integer  "certification_level_id"
    t.string   "membership_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "certification_date"
    t.boolean  "primary",                :default => false
  end

  add_index "certification_level_memberships", ["certification_level_id", "memberable_id", "memberable_type"], :name => "idx_certification_level_id_memberable"
  add_index "certification_level_memberships", ["certification_level_id"], :name => "index_certification_level_memberships_on_certification_level_id"
  add_index "certification_level_memberships", ["memberable_id", "memberable_type"], :name => "idx_memberable"

  create_table "certification_levels", :force => true do |t|
    t.integer  "certification_agency_id"
    t.integer  "store_id"
    t.string   "name",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
  end

  add_index "certification_levels", ["certification_agency_id"], :name => "index_certification_levels_on_certification_agency_id"
  add_index "certification_levels", ["name", "certification_agency_id", "store_id"], :name => "idx_certification_agency"
  add_index "certification_levels", ["store_id"], :name => "index_certification_levels_on_dive_shop_id"

  create_table "commission_rates", :force => true do |t|
    t.integer  "store_id"
    t.float    "amount",     :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "commission_rates", ["store_id"], :name => "index_commission_rates_on_dive_shop_id"

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "telephone"
    t.string   "email"
    t.string   "website_url",        :limit => 2048
    t.boolean  "enabled",                            :default => true
    t.string   "api_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "primary_contact_id"
    t.string   "referral_code"
    t.string   "invite_code"
    t.string   "tax_id"
    t.string   "outbound_email"
    t.string   "mailgun_id"
  end

  add_index "companies", ["outbound_email"], :name => "index_companies_on_outbound_email", :unique => true
  add_index "companies", ["referral_code"], :name => "index_dive_centres_on_referral_code", :unique => true

  create_table "credit_note_payment_histories", :force => true do |t|
    t.integer  "sale_id"
    t.integer  "customer_id"
    t.decimal  "initial_value",   :precision => 8, :scale => 2
    t.decimal  "remaining_value", :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_note_payment_histories", ["customer_id"], :name => "index_credit_note_payment_histories_on_customer_id"
  add_index "credit_note_payment_histories", ["sale_id"], :name => "index_credit_note_payment_histories_on_sale_id"

  create_table "credit_notes", :force => true do |t|
    t.integer  "sale_id"
    t.integer  "customer_id"
    t.decimal  "initial_value",   :precision => 8, :scale => 2
    t.decimal  "remaining_value", :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_notes", ["customer_id"], :name => "index_credit_notes_on_customer_id"
  add_index "credit_notes", ["sale_id"], :name => "index_credit_notes_on_sale_id"

  create_table "currencies", :force => true do |t|
    t.string   "name",                                        :null => false
    t.string   "unit",                                        :null => false
    t.string   "code",       :limit => 3,                     :null => false
    t.string   "separator",               :default => ".",    :null => false
    t.string   "delimiter",               :default => ",",    :null => false
    t.string   "format",                  :default => "%u%n", :null => false
    t.integer  "precision",               :default => 2,      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies", ["code"], :name => "index_currencies_on_code", :unique => true

  create_table "custom_fields", :force => true do |t|
    t.integer  "customer_id"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_fields", ["customer_id"], :name => "index_custom_fields_on_customer_id"

  create_table "customer_experience_levels", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", :force => true do |t|
    t.integer  "company_id",                                                                    :null => false
    t.integer  "customer_experience_level_id"
    t.string   "given_name"
    t.string   "family_name"
    t.decimal  "default_discount_level",       :precision => 8, :scale => 2, :default => 0.0
    t.string   "source"
    t.string   "telephone"
    t.string   "mobile_phone"
    t.string   "email"
    t.string   "fins"
    t.string   "bcd"
    t.string   "wetsuit"
    t.integer  "number_of_logged_dives",                                     :default => 0
    t.date     "born_on"
    t.date     "last_dive_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "hotel_name"
    t.string   "room_number"
    t.string   "gender"
    t.decimal  "credit_note",                  :precision => 8, :scale => 2, :default => 0.0
    t.string   "emergency_contact_details"
    t.boolean  "fins_own"
    t.boolean  "bcd_own"
    t.boolean  "wetsuit_own"
    t.string   "weight"
    t.boolean  "mask_own"
    t.boolean  "regulator_own"
    t.boolean  "send_event_related_emails",                                  :default => true
    t.string   "tax_id"
    t.boolean  "zero_tax_rate",                                              :default => false
  end

  add_index "customers", ["company_id"], :name => "index_customers_on_dive_centre_id"
  add_index "customers", ["customer_experience_level_id"], :name => "index_customers_on_customer_experience_level_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "discounts", :force => true do |t|
    t.integer  "discountable_id"
    t.string   "discountable_type"
    t.decimal  "value",             :precision => 11, :scale => 2, :default => 0.0
    t.string   "kind",                                             :default => "percent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discounts", ["discountable_id", "discountable_type"], :name => "index_discounts_on_discountable_id_and_discountable_type"

  create_table "diver_types", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "diver_types", ["name"], :name => "index_diver_types_on_name"

  create_table "documentation_pages", :force => true do |t|
    t.string   "title"
    t.string   "permalink"
    t.text     "content"
    t.text     "compiled_content"
    t.integer  "parent_id"
    t.integer  "position"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "email_settings", :force => true do |t|
    t.integer  "store_id"
    t.text     "booking_confirmed_content"
    t.boolean  "include_sale_receipt_to_booking_confirmed",             :default => true
    t.boolean  "disable_booking_confirmed_email",                       :default => false
    t.text     "event_reminder_content"
    t.time     "time_to_send_event_reminder",                           :default => '2000-01-01 00:00:00'
    t.boolean  "disable_event_reminder_email",                          :default => false
    t.text     "online_event_booking_content"
    t.boolean  "include_sale_receipt_to_online_event_booking",          :default => true
    t.boolean  "disable_online_event_booking_email",                    :default => false
    t.text     "sales_receipt_content"
    t.boolean  "disable_sales_receipt_email",                           :default => false
    t.text     "service_ready_for_collection_content"
    t.boolean  "include_sales_receipt_to_service_ready_for_collection", :default => true
    t.boolean  "disable_service_ready_for_collection_email",            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disable_low_inventory_product_reminder_email",          :default => false
    t.text     "rental_receipt_content"
    t.boolean  "disable_rental_receipt_email",                          :default => false,                 :null => false
    t.string   "language",                                              :default => "en"
  end

  add_index "email_settings", ["store_id"], :name => "index_email_settings_on_dive_shop_id"

  create_table "event_customer_participant_options", :force => true do |t|
    t.string   "type"
    t.integer  "event_customer_participant_id"
    t.integer  "additional_id"
    t.integer  "number_of_days"
    t.integer  "insurance_id"
    t.boolean  "free",                          :default => false
    t.integer  "kit_hire_id"
    t.integer  "transport_id"
    t.string   "information"
    t.time     "time"
    t.date     "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_customer_participant_options", ["additional_id"], :name => "index_event_customer_participant_options_on_additional_id"
  add_index "event_customer_participant_options", ["event_customer_participant_id"], :name => "event_customer_participant_option_participant"
  add_index "event_customer_participant_options", ["insurance_id"], :name => "index_event_customer_participant_options_on_insurance_id"
  add_index "event_customer_participant_options", ["kit_hire_id"], :name => "index_event_customer_participant_options_on_kit_hire_id"
  add_index "event_customer_participant_options", ["transport_id"], :name => "index_event_customer_participant_options_on_transport_id"

  create_table "event_customer_participants", :force => true do |t|
    t.integer  "event_id"
    t.integer  "customer_id"
    t.integer  "event_user_participant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price",                     :precision => 11, :scale => 2
    t.string   "status"
    t.boolean  "need_show",                                                :default => false, :null => false
    t.boolean  "local_event"
    t.integer  "nitrox",                                                   :default => 0
    t.float    "smart_line_item_price"
    t.text     "note"
    t.datetime "deleted_at"
    t.string   "group_name"
    t.integer  "quantity",                                                 :default => 1
    t.string   "contact_information"
  end

  add_index "event_customer_participants", ["customer_id"], :name => "index_event_customer_participants_on_customer_id"
  add_index "event_customer_participants", ["event_id"], :name => "index_event_customer_participants_on_event_id"
  add_index "event_customer_participants", ["event_user_participant_id"], :name => "index_event_customer_participants_on_event_user_participant_id"

  create_table "event_tariffs", :force => true do |t|
    t.integer  "store_id"
    t.string   "name"
    t.integer  "min"
    t.integer  "max"
    t.float    "percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_trips", :force => true do |t|
    t.integer  "store_id"
    t.integer  "tax_rate_id"
    t.integer  "commission_rate_id"
    t.string   "name",                                                                    :null => false
    t.decimal  "cost",                  :precision => 8,  :scale => 2
    t.decimal  "commission_rate_money", :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "exclude_tariff_rates",                                 :default => false
    t.decimal  "local_cost",            :precision => 8,  :scale => 2
  end

  add_index "event_trips", ["commission_rate_id"], :name => "index_event_trips_on_commission_rate_id"
  add_index "event_trips", ["store_id"], :name => "index_event_trips_on_dive_shop_id"
  add_index "event_trips", ["tax_rate_id"], :name => "index_event_trips_on_tax_rate_id"

  create_table "event_types", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_types", ["name"], :name => "index_event_types_on_name"

  create_table "event_user_participants", :force => true do |t|
    t.integer  "event_id",   :null => false
    t.integer  "user_id",    :null => false
    t.string   "role",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_user_participants", ["event_id"], :name => "index_event_user_participants_on_event_id"
  add_index "event_user_participants", ["user_id", "event_id"], :name => "index_event_user_participants_on_user_id_and_event_id"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.integer  "event_type_id"
    t.integer  "certification_level_id"
    t.integer  "event_trip_id"
    t.datetime "starts_at",                                                                :null => false
    t.datetime "ends_at",                                                                  :null => false
    t.string   "additional_equipment"
    t.decimal  "price",                  :precision => 11, :scale => 2
    t.boolean  "private",                                               :default => false
    t.integer  "store_id",                                                                 :null => false
    t.string   "frequency",                                                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.text     "notes"
    t.boolean  "enable_booking",                                        :default => true,  :null => false
    t.integer  "limit_of_registrations"
    t.string   "location"
    t.text     "instructions"
    t.boolean  "cancel",                                                :default => false
    t.integer  "boat_id"
    t.integer  "number_of_frequencies",                                 :default => 0
    t.integer  "number_of_dives",                                       :default => 0
    t.string   "type"
    t.datetime "deleted_at"
    t.boolean  "all_day",                                               :default => false, :null => false
  end

  add_index "events", ["boat_id"], :name => "index_events_on_boat_id"
  add_index "events", ["certification_level_id"], :name => "index_events_on_certification_level_id"
  add_index "events", ["event_trip_id"], :name => "index_events_on_event_trip_id"
  add_index "events", ["event_type_id"], :name => "index_events_on_event_type_id"
  add_index "events", ["parent_id"], :name => "index_events_on_parent_id"
  add_index "events", ["store_id"], :name => "index_events_on_dive_shop_id"

  create_table "extra_events", :force => true do |t|
    t.string   "type",                                       :null => false
    t.integer  "store_id"
    t.integer  "tax_rate_id"
    t.string   "name",                                       :null => false
    t.decimal  "cost",        :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "extra_events", ["store_id"], :name => "index_extra_events_on_dive_shop_id"
  add_index "extra_events", ["tax_rate_id"], :name => "index_extra_events_on_tax_rate_id"

  create_table "finance_report_payments", :force => true do |t|
    t.integer  "finance_report_id"
    t.string   "name"
    t.decimal  "amount",            :precision => 11, :scale => 2
    t.decimal  "custom_amount",     :precision => 11, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_id"
  end

  add_index "finance_report_payments", ["finance_report_id"], :name => "index_finance_report_payments_on_finance_report_id"
  add_index "finance_report_payments", ["payment_id"], :name => "index_finance_report_payments_on_payment_id"

  create_table "finance_reports", :force => true do |t|
    t.integer  "store_id"
    t.integer  "working_time_id"
    t.decimal  "total_payments",    :precision => 8, :scale => 2
    t.decimal  "discounts",         :precision => 8, :scale => 2
    t.decimal  "tax_total",         :precision => 8, :scale => 2
    t.decimal  "complete_payments", :precision => 8, :scale => 2
    t.boolean  "sent",                                            :default => false
    t.string   "xero_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "xero_invoice_id"
  end

  add_index "finance_reports", ["store_id"], :name => "index_finance_reports_on_dive_shop_id"
  add_index "finance_reports", ["working_time_id"], :name => "index_finance_reports_on_working_time_id"

  create_table "gift_card_types", :force => true do |t|
    t.integer  "company_id"
    t.decimal  "value",      :precision => 8, :scale => 2, :default => 0.0
    t.integer  "valid_for"
    t.integer  "integer"
    t.string   "uniq_id"
    t.boolean  "can_sold",                                 :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "gift_card_types", ["uniq_id"], :name => "index_gift_card_types_on_uniq_id"

  create_table "gift_cards", :force => true do |t|
    t.integer  "gift_card_type_id"
    t.string   "uniq_id"
    t.string   "status"
    t.datetime "solded_at"
    t.decimal  "available_balance", :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gift_cards", ["uniq_id"], :name => "index_gift_cards_on_uniq_id"

  create_table "images", :force => true do |t|
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size",    :default => 0
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["imageable_id", "imageable_type"], :name => "index_images_on_imageable_id_and_imageable_type", :unique => true

  create_table "incidents", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "creator_id"
    t.text     "description"
    t.datetime "occurred_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "incidents", ["creator_id"], :name => "index_incidents_on_creator_id"
  add_index "incidents", ["customer_id"], :name => "index_incidents_on_customer_id"

  create_table "kits", :force => true do |t|
    t.integer  "service_id"
    t.integer  "type_of_service_id"
    t.string   "kit"
    t.string   "serial_number"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "kits", ["service_id"], :name => "index_kits_on_service_id"
  add_index "kits", ["type_of_service_id"], :name => "index_kits_on_type_of_service_id"

  create_table "material_prices", :force => true do |t|
    t.integer  "certification_level_cost_id"
    t.integer  "tax_rate_id"
    t.decimal  "price"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "material_prices", ["certification_level_cost_id"], :name => "index_material_prices_on_certification_level_cost_id"
  add_index "material_prices", ["tax_rate_id"], :name => "index_material_prices_on_tax_rate_id"

  create_table "miscellaneous_products", :force => true do |t|
    t.integer  "store_id"
    t.integer  "category_id"
    t.integer  "tax_rate_id"
    t.decimal  "price",       :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.text     "description"
  end

  add_index "miscellaneous_products", ["category_id"], :name => "index_miscellaneous_products_on_category_id"
  add_index "miscellaneous_products", ["store_id"], :name => "index_miscellaneous_products_on_dive_shop_id"
  add_index "miscellaneous_products", ["tax_rate_id"], :name => "index_miscellaneous_products_on_tax_rate_id"

  create_table "mobi_squad_online_customers", :force => true do |t|
    t.integer  "dive_shop_id"
    t.text     "details"
    t.string   "customer_uuid"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "mobi_squad_online_customers", ["customer_uuid"], :name => "index_mobi_squad_online_customers_on_customer_uuid"
  add_index "mobi_squad_online_customers", ["dive_shop_id"], :name => "index_mobi_squad_online_customers_on_dive_shop_id"

  create_table "notes", :force => true do |t|
    t.integer  "notable_id"
    t.string   "notable_type"
    t.integer  "creator_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["creator_id"], :name => "index_notes_on_creator_id"
  add_index "notes", ["notable_id", "notable_type"], :name => "index_notes_on_notable_id_and_notable_type"
  add_index "notes", ["notable_type", "notable_id"], :name => "index_notes_on_notable_type_and_notable_id"

  create_table "payment_credentials", :force => true do |t|
    t.integer  "company_id"
    t.string   "paypal_login"
    t.string   "paypal_password"
    t.string   "paypal_signature"
    t.string   "stripe_secret_key"
    t.string   "stripe_publishable_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "epay_merchant_number"
    t.string   "epay_password"
    t.string   "epay_currency"
  end

  add_index "payment_credentials", ["company_id"], :name => "index_payment_credentials_on_dive_centre_id"

  create_table "payment_methods", :force => true do |t|
    t.integer  "store_id"
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "xero_code"
    t.datetime "deleted_at"
  end

  add_index "payment_methods", ["store_id"], :name => "index_payment_methods_on_dive_shop_id"

  create_table "promo_codes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "code"
    t.string   "code_status",        :default => "Active"
    t.integer  "value",              :default => 0
    t.string   "duration",           :default => "once",   :null => false
    t.integer  "duration_in_months"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promo_codes", ["code"], :name => "index_promo_codes_on_code"

  create_table "purchase_order_items", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "product_id"
    t.integer  "quantity",                                        :default => 0,   :null => false
    t.decimal  "price",             :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.integer  "quantity_rejected",                               :default => 0,   :null => false
  end

  add_index "purchase_order_items", ["product_id"], :name => "index_purchase_order_items_on_product_id"
  add_index "purchase_order_items", ["purchase_order_id"], :name => "index_purchase_order_items_on_purchase_order_id"

  create_table "purchase_orders", :force => true do |t|
    t.integer  "supplier_id"
    t.integer  "delivery_location_id",                                                      :null => false
    t.date     "expected_delivery"
    t.string   "status",                                             :default => "pending"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
    t.integer  "creator_id",                                                                :null => false
    t.decimal  "grand_total",          :precision => 8, :scale => 2, :default => 0.0,       :null => false
    t.text     "note"
    t.decimal  "fixed_total",          :precision => 8, :scale => 2, :default => 0.0,       :null => false
  end

  add_index "purchase_orders", ["creator_id"], :name => "index_purchase_orders_on_creator_id"
  add_index "purchase_orders", ["delivery_location_id"], :name => "index_purchase_orders_on_delivery_location_id"
  add_index "purchase_orders", ["supplier_id"], :name => "index_purchase_orders_on_supplier_id"

  create_table "recurring_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rentals", :force => true do |t|
    t.integer  "user_id"
    t.integer  "customer_id"
    t.integer  "store_id"
    t.datetime "pickup_date"
    t.datetime "return_date"
    t.string   "status"
    t.decimal  "amount",          :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.text     "note"
    t.decimal  "grand_total",     :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "change",          :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.datetime "completed_at"
    t.string   "xero_invoice_id"
  end

  add_index "rentals", ["customer_id"], :name => "index_rentals_on_customer_id"
  add_index "rentals", ["store_id"], :name => "index_rentals_on_dive_shop_id"
  add_index "rentals", ["user_id"], :name => "index_rentals_on_user_id"

  create_table "renteds", :force => true do |t|
    t.integer  "rental_id"
    t.integer  "rental_product_id"
    t.integer  "quantity",                                            :default => 1,   :null => false
    t.decimal  "item_amount",           :precision => 8, :scale => 2, :default => 0.0
    t.float    "tax_rate"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.float    "smart_line_item_price"
  end

  add_index "renteds", ["rental_id"], :name => "index_renteds_on_rental_id"
  add_index "renteds", ["rental_product_id"], :name => "index_renteds_on_rental_product_id"

  create_table "sale_customers", :force => true do |t|
    t.integer  "sale_id"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ignore_events", :default => false
  end

  add_index "sale_customers", ["customer_id"], :name => "index_sale_customers_on_customer_id"
  add_index "sale_customers", ["sale_id", "customer_id"], :name => "index_sale_customers_on_sale_id_and_customer_id", :unique => true
  add_index "sale_customers", ["sale_id"], :name => "index_sale_customers_on_sale_id"

  create_table "sale_products", :force => true do |t|
    t.integer  "sale_id"
    t.integer  "quantity",                                            :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "original_id"
    t.integer  "sale_productable_id"
    t.string   "sale_productable_type"
    t.decimal  "price",                 :precision => 8, :scale => 2
    t.float    "tax_rate"
    t.float    "commission_rate"
    t.float    "smart_line_item_price"
  end

  add_index "sale_products", ["original_id"], :name => "index_sale_products_on_original_id"
  add_index "sale_products", ["sale_id"], :name => "index_sale_products_on_sale_id"
  add_index "sale_products", ["sale_productable_id", "sale_productable_type"], :name => "idx_sale_productable_id_and_sale_productable_type"

  create_table "sales", :force => true do |t|
    t.integer  "store_id"
    t.integer  "creator_id"
    t.string   "status",                                                   :default => "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "grand_total",               :precision => 11, :scale => 2, :default => 0.0
    t.decimal  "change",                    :precision => 11, :scale => 2, :default => 0.0
    t.boolean  "booking",                                                  :default => false,    :null => false
    t.integer  "parent_id"
    t.text     "note"
    t.decimal  "tax_rate_total",            :precision => 11, :scale => 2
    t.decimal  "taxable_revenue",           :precision => 11, :scale => 2
    t.decimal  "cost_of_goods",             :precision => 11, :scale => 2, :default => 0.0
    t.integer  "receipt_id"
    t.float    "course_events_total_price"
    t.float    "other_events_total_price"
    t.datetime "completed_at"
    t.datetime "deleted_at"
    t.string   "xero_invoice_id"
  end

  add_index "sales", ["creator_id"], :name => "index_sales_on_creator_id"
  add_index "sales", ["status"], :name => "index_sales_on_status"
  add_index "sales", ["store_id"], :name => "index_sales_on_dive_shop_id"

  create_table "scuba_tribes", :force => true do |t|
    t.integer  "store_id"
    t.string   "api_key"
    t.string   "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "scuba_tribes", ["store_id"], :name => "index_scuba_tribes_on_store_id"

  create_table "service_items", :force => true do |t|
    t.integer  "service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_id"
  end

  add_index "service_items", ["product_id"], :name => "index_service_items_on_product_id"
  add_index "service_items", ["service_id"], :name => "index_service_items_on_service_id"

  create_table "service_kits", :force => true do |t|
    t.integer  "store_id"
    t.string   "name"
    t.integer  "stock_level"
    t.decimal  "supply_price",       :precision => 8, :scale => 2
    t.decimal  "retail_price",       :precision => 8, :scale => 2
    t.integer  "type_of_service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tax_rate_id"
  end

  add_index "service_kits", ["store_id"], :name => "index_service_kits_on_dive_shop_id"
  add_index "service_kits", ["tax_rate_id"], :name => "index_service_kits_on_tax_rate_id"
  add_index "service_kits", ["type_of_service_id"], :name => "index_service_kits_on_type_of_service_id"

  create_table "services", :force => true do |t|
    t.integer  "type_of_service_id"
    t.string   "serial_number"
    t.integer  "customer_id"
    t.integer  "user_id"
    t.date     "booked_in"
    t.date     "collection_date"
    t.string   "status"
    t.string   "barcode"
    t.integer  "store_id"
    t.boolean  "complimentary_service", :default => false
    t.string   "kit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "sale_id"
  end

  add_index "services", ["customer_id"], :name => "index_services_on_customer_id"
  add_index "services", ["sale_id"], :name => "index_services_on_sale_id"
  add_index "services", ["store_id"], :name => "index_services_on_dive_shop_id"
  add_index "services", ["type_of_service_id"], :name => "index_services_on_type_of_service_id"
  add_index "services", ["user_id"], :name => "index_services_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "smart_list_conditions", :force => true do |t|
    t.integer  "smart_list_id"
    t.string   "resource"
    t.string   "which"
    t.string   "how_many"
    t.float    "value",         :default => 0.0
    t.string   "when"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "smart_list_conditions", ["smart_list_id"], :name => "index_smart_list_conditions_on_smart_list_id"

  create_table "smart_lists", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "join_operator"
  end

  add_index "smart_lists", ["company_id"], :name => "index_smart_lists_on_dive_centre_id"

  create_table "store_products", :force => true do |t|
    t.integer  "store_id"
    t.integer  "category_id"
    t.integer  "brand_id"
    t.integer  "supplier_id"
    t.integer  "tax_rate_id"
    t.integer  "commission_rate_id"
    t.string   "name"
    t.string   "sku_code"
    t.integer  "number_in_stock",                                       :default => 0
    t.text     "description"
    t.string   "accounting_code"
    t.string   "supplier_code"
    t.decimal  "supply_price",           :precision => 8,  :scale => 2, :default => 0.0
    t.decimal  "retail_price",           :precision => 8,  :scale => 2
    t.decimal  "commission_rate_money",  :precision => 10, :scale => 0
    t.float    "markup",                                                :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "barcode"
    t.integer  "low_inventory_reminder",                                :default => 5
    t.datetime "sended_at"
    t.decimal  "offer_price",            :precision => 8,  :scale => 2
    t.boolean  "archived",                                              :default => false, :null => false
    t.string   "type"
    t.decimal  "price_per_day",          :precision => 11, :scale => 2
  end

  add_index "store_products", ["brand_id"], :name => "index_products_on_brand_id"
  add_index "store_products", ["category_id"], :name => "index_products_on_category_id"
  add_index "store_products", ["commission_rate_id"], :name => "index_products_on_commission_rate_id"
  add_index "store_products", ["name"], :name => "index_products_on_name"
  add_index "store_products", ["sku_code"], :name => "index_products_on_sku_code"
  add_index "store_products", ["store_id"], :name => "index_products_on_dive_shop_id"
  add_index "store_products", ["supplier_id"], :name => "index_products_on_supplier_id"
  add_index "store_products", ["tax_rate_id"], :name => "index_products_on_tax_rate_id"

  create_table "stores", :force => true do |t|
    t.integer  "company_id",                                                 :null => false
    t.string   "name",                   :limit => 50,                       :null => false
    t.string   "location",               :limit => 50,                       :null => false
    t.string   "public_key"
    t.string   "api_key"
    t.integer  "currency_id",                                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "printer_type",                         :default => "80mm",   :null => false
    t.string   "time_zone",                            :default => "London", :null => false
    t.boolean  "main",                                 :default => false,    :null => false
    t.string   "invoice_id"
    t.string   "calendar_type",                        :default => "month"
    t.text     "standart_term"
    t.string   "barcode_printing_type",                :default => "a4"
    t.boolean  "tax_rate_inclusion",                   :default => true
    t.string   "tsp_url"
    t.text     "standart_rental_term"
    t.string   "invoice_title"
    t.string   "receipt_title"
    t.text     "calendar_header"
    t.text     "calendar_footer"
    t.integer  "initial_receipt_number"
  end

  add_index "stores", ["api_key"], :name => "index_dive_shops_on_api_key"
  add_index "stores", ["company_id"], :name => "index_dive_shops_on_dive_centre_id"
  add_index "stores", ["currency_id"], :name => "index_dive_shops_on_currency_id"
  add_index "stores", ["public_key"], :name => "index_dive_shops_on_public_key"

  create_table "stores_users", :id => false, :force => true do |t|
    t.integer "user_id",  :null => false
    t.integer "store_id", :null => false
  end

  add_index "stores_users", ["store_id"], :name => "index_dive_shops_users_on_dive_shop_id"
  add_index "stores_users", ["user_id"], :name => "index_dive_shops_users_on_user_id"

  create_table "suppliers", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "telephone"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "suppliers", ["company_id"], :name => "index_suppliers_on_dive_centre_id"
  add_index "suppliers", ["name"], :name => "index_suppliers_on_name"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tax_rates", :force => true do |t|
    t.integer  "store_id"
    t.float    "amount",     :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier"
    t.datetime "deleted_at"
  end

  add_index "tax_rates", ["store_id"], :name => "index_tax_rates_on_dive_shop_id"

  create_table "tills", :force => true do |t|
    t.integer  "store_id"
    t.integer  "user_id"
    t.text     "notes"
    t.boolean  "take_out",                                  :default => true
    t.decimal  "amount",     :precision => 10, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
  end

  add_index "tills", ["store_id"], :name => "index_tills_on_dive_shop_id"
  add_index "tills", ["user_id"], :name => "index_tills_on_user_id"

  create_table "time_intervals", :force => true do |t|
    t.integer  "service_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "time_intervals", ["service_id"], :name => "index_time_intervals_on_service_id"
  add_index "time_intervals", ["user_id"], :name => "index_time_intervals_on_user_id"

  create_table "type_of_services", :force => true do |t|
    t.integer  "store_id"
    t.string   "name"
    t.float    "labour"
    t.string   "price_of_service_kit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "labour_price"
    t.integer  "tax_rate_id"
  end

  add_index "type_of_services", ["store_id"], :name => "index_type_of_services_on_dive_shop_id"
  add_index "type_of_services", ["tax_rate_id"], :name => "index_type_of_services_on_tax_rate_id"

  create_table "user_holidays", :force => true do |t|
    t.integer  "user_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                                                                                                                                                                                                             :null => false
    t.string   "encrypted_password",                     :limit => 128,                                                                                                                                                                             :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                                                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "time_zone",                                                                            :default => "London",                                                                                                                        :null => false
    t.string   "role",                                                                                 :default => "manager",                                                                                                                       :null => false
    t.integer  "company_id",                                                                                                                                                                                                                        :null => false
    t.string   "current_step"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "authentication_token"
    t.string   "given_name"
    t.string   "family_name"
    t.string   "alternative_email"
    t.string   "telephone"
    t.string   "emergency_contact_details"
    t.string   "available_days",                                                                       :default => "---\n:monday: false\n:tuesday: false\n:wednesday: false\n:thursday: false\n:friday: false\n:saturday: false\n:sunday: false\n"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "contracted_hours"
    t.string   "mailchimp_api_key"
    t.string   "mailchimp_list_id_for_customer"
    t.string   "mailchimp_list_id_for_staff_member"
    t.string   "mailchimp_list_id_for_business_contact"
    t.string   "locale",                                                                               :default => "en"
    t.decimal  "sale_target",                                           :precision => 11, :scale => 2
    t.boolean  "sale_target_show_dashboard",                                                           :default => true
    t.string   "instructor_number"
    t.text     "overtime"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["company_id"], :name => "index_users_on_dive_centre_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "working_times", :force => true do |t|
    t.integer  "store_id"
    t.integer  "opened_user_id"
    t.integer  "closed_user_id"
    t.datetime "open_at"
    t.datetime "close_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "working_times", ["closed_user_id"], :name => "index_working_times_on_closed_user_id"
  add_index "working_times", ["opened_user_id"], :name => "index_working_times_on_opened_user_id"
  add_index "working_times", ["store_id"], :name => "index_working_times_on_dive_shop_id"

  create_table "xeros", :force => true do |t|
    t.string   "xero_consumer_key"
    t.string   "xero_consumer_secret"
    t.integer  "store_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "xero_session_handle"
    t.string   "default_sale_account"
    t.string   "rounding_errors_account"
    t.string   "till_payment_discrepancies"
    t.string   "cost_of_goods_sold"
    t.datetime "expires_at"
    t.string   "contact_remote_id"
    t.boolean  "valid_tax_rate",             :default => false
    t.string   "integration_type"
    t.datetime "last_synced_at"
  end

  add_index "xeros", ["store_id"], :name => "index_xeros_on_dive_shop_id"

end
