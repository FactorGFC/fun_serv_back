# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_24_230002) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "cities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "state_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "contributor_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address_type", null: false
    t.string "suburb", null: false
    t.string "suburb_type"
    t.string "street", null: false
    t.integer "external_number", null: false
    t.string "apartment_number"
    t.integer "postal_code", null: false
    t.string "address_reference"
    t.uuid "state_id", null: false
    t.uuid "municipality_id", null: false
    t.uuid "contributor_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contributor_id"], name: "index_contributor_addresses_on_contributor_id"
    t.index ["municipality_id"], name: "index_contributor_addresses_on_municipality_id"
    t.index ["state_id"], name: "index_contributor_addresses_on_state_id"
  end

  create_table "contributor_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "status", null: false
    t.string "notes"
    t.string "url"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "contributor_id", null: false
    t.uuid "file_type_document_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contributor_id"], name: "index_contributor_documents_on_contributor_id"
    t.index ["file_type_document_id"], name: "index_contributor_documents_on_file_type_document_id"
  end

  create_table "contributors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "contributor_type", null: false
    t.string "bank"
    t.bigint "account_number"
    t.bigint "clabe"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "person_id"
    t.uuid "legal_entity_id"
    t.index ["legal_entity_id"], name: "index_contributors_on_legal_entity_id"
    t.index ["person_id"], name: "index_contributors_on_person_id"
  end

  create_table "countries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "sortname", null: false
    t.string "name", null: false
    t.integer "phonecode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "credit_ratings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "description", null: false
    t.decimal "value", precision: 15, scale: 4, null: false
    t.string "cr_type"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "customer_credits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "total_requested", precision: 15, scale: 4, null: false
    t.decimal "capital", precision: 15, scale: 4, null: false
    t.decimal "interests", precision: 15, scale: 4, null: false
    t.decimal "iva", precision: 15, scale: 4, null: false
    t.decimal "total_debt", precision: 15, scale: 4, null: false
    t.decimal "total_payments", precision: 15, scale: 4, null: false
    t.decimal "balance", precision: 15, scale: 4, null: false
    t.string "status", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "customer_id", null: false
    t.uuid "project_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "fixed_payment", precision: 15, scale: 4, null: false
    t.integer "restructure_term"
    t.uuid "project_request_id"
    t.index ["customer_id"], name: "index_customer_credits_on_customer_id"
    t.index ["project_id"], name: "index_customer_credits_on_project_id"
    t.index ["project_request_id"], name: "index_customer_credits_on_project_request_id"
  end

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "customer_type", null: false
    t.string "status", null: false
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "contributor_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "file_type_id"
    t.index ["contributor_id"], name: "index_customers_on_contributor_id"
    t.index ["file_type_id"], name: "index_customers_on_file_type_id"
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "document_type", null: false
    t.string "name", null: false
    t.string "description", null: false
    t.string "validation"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "ext_service_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ext_service_id"], name: "index_documents_on_ext_service_id"
  end

  create_table "ext_rates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "description", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.decimal "value", precision: 15, scale: 4, null: false
    t.string "rate_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ext_services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "supplier", null: false
    t.string "user", null: false
    t.string "api_key"
    t.string "token"
    t.string "url", null: false
    t.string "rule"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "file_type_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "document_id", null: false
    t.uuid "file_type_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["document_id"], name: "index_file_type_documents_on_document_id"
    t.index ["file_type_id"], name: "index_file_type_documents_on_file_type_id"
  end

  create_table "file_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.string "customer_type"
    t.string "funder_type"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "funders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "funder_type", null: false
    t.string "status", null: false
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "contributor_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "file_type_id"
    t.index ["contributor_id"], name: "index_funders_on_contributor_id"
    t.index ["file_type_id"], name: "index_funders_on_file_type_id"
    t.index ["user_id"], name: "index_funders_on_user_id"
  end

  create_table "funding_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "total_requested", precision: 15, scale: 4, null: false
    t.decimal "total_investments", precision: 15, scale: 4, null: false
    t.decimal "balance", precision: 15, scale: 4, null: false
    t.date "funding_request_date", null: false
    t.date "funding_due_date", null: false
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", null: false
    t.index ["project_id"], name: "index_funding_requests_on_project_id"
  end

  create_table "general_parameters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "table"
    t.integer "id_table"
    t.string "key", null: false
    t.string "description", null: false
    t.string "used_values"
    t.string "value", null: false
    t.string "documentation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "investments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "total", precision: 15, scale: 4, null: false
    t.decimal "rate", precision: 15, scale: 4, null: false
    t.date "investment_date", null: false
    t.string "status", null: false
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "funding_request_id", null: false
    t.uuid "funder_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "yield_fixed_payment", precision: 15, scale: 4, null: false
    t.index ["funder_id"], name: "index_investments_on_funder_id"
    t.index ["funding_request_id"], name: "index_investments_on_funding_request_id"
  end

  create_table "legal_entities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "fiscal_regime", null: false
    t.string "rfc", null: false
    t.string "rug"
    t.string "business_name", null: false
    t.string "phone"
    t.string "mobile"
    t.string "email"
    t.string "business_email"
    t.string "main_activity"
    t.boolean "fiel"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "domain", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["domain", "key"], name: "index_lists_on_domain_and_key", unique: true
  end

  create_table "municipalities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "municipality_key", null: false
    t.string "name", null: false
    t.uuid "state_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["state_id"], name: "index_municipalities_on_state_id"
  end

  create_table "my_apps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "title"
    t.string "app_id"
    t.string "javascript_origins"
    t.string "secret_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_my_apps_on_user_id"
  end

  create_table "options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.string "group"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "payment_periods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "description", null: false
    t.integer "value", null: false
    t.string "pp_type"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "fiscal_regime", null: false
    t.string "rfc", null: false
    t.string "curp"
    t.bigint "imss"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "second_last_name", null: false
    t.string "gender"
    t.string "nationality"
    t.string "birth_country"
    t.string "birthplace"
    t.date "birthdate", null: false
    t.string "martial_status"
    t.string "id_type"
    t.bigint "identification", null: false
    t.string "phone"
    t.string "mobile"
    t.string "email"
    t.boolean "fiel"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "postal_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "pc", null: false
    t.string "suburb_type"
    t.string "suburb", null: false
    t.string "municipality", null: false
    t.string "state", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pc"], name: "index_postal_codes_on_pc"
  end

  create_table "project_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "project_type", null: false
    t.string "folio", null: false
    t.string "currency", null: false
    t.decimal "total", precision: 15, scale: 4, null: false
    t.date "request_date", null: false
    t.string "status", null: false
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "customer_id", null: false
    t.uuid "user_id", null: false
    t.uuid "term_id", null: false
    t.uuid "payment_period_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "rate", precision: 15, scale: 4
    t.index ["customer_id"], name: "index_project_requests_on_customer_id"
    t.index ["payment_period_id"], name: "index_project_requests_on_payment_period_id"
    t.index ["term_id"], name: "index_project_requests_on_term_id"
    t.index ["user_id"], name: "index_project_requests_on_user_id"
  end

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "project_type", null: false
    t.string "folio", null: false
    t.decimal "client_rate", precision: 15, scale: 4, null: false
    t.decimal "funder_rate", precision: 15, scale: 4, null: false
    t.decimal "ext_rate", precision: 15, scale: 4, null: false
    t.decimal "total", precision: 15, scale: 4, null: false
    t.decimal "interests", precision: 15, scale: 4, null: false
    t.decimal "financial_cost", precision: 15, scale: 4, null: false
    t.string "currency", null: false
    t.date "entry_date", null: false
    t.date "used_date"
    t.string "status", null: false
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "customer_id", null: false
    t.uuid "user_id", null: false
    t.uuid "project_request_id", null: false
    t.uuid "term_id", null: false
    t.uuid "payment_period_id", null: false
    t.uuid "credit_rating_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credit_rating_id"], name: "index_projects_on_credit_rating_id"
    t.index ["customer_id"], name: "index_projects_on_customer_id"
    t.index ["payment_period_id"], name: "index_projects_on_payment_period_id"
    t.index ["project_request_id"], name: "index_projects_on_project_request_id"
    t.index ["term_id"], name: "index_projects_on_term_id"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "rates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "description", null: false
    t.string "value", null: false
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "term_id", null: false
    t.uuid "payment_period_id", null: false
    t.uuid "credit_rating_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credit_rating_id"], name: "index_rates_on_credit_rating_id"
    t.index ["payment_period_id"], name: "index_rates_on_payment_period_id"
    t.index ["term_id"], name: "index_rates_on_term_id"
  end

  create_table "role_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "role_id", null: false
    t.uuid "option_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["option_id"], name: "index_role_options_on_option_id"
    t.index ["role_id"], name: "index_role_options_on_role_id"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sim_customer_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "pay_number", null: false
    t.decimal "remaining_debt", precision: 15, scale: 4, null: false
    t.decimal "payment", precision: 15, scale: 4, null: false
    t.decimal "capital", precision: 15, scale: 4, null: false
    t.decimal "interests", precision: 15, scale: 4, null: false
    t.decimal "iva", precision: 15, scale: 4, null: false
    t.string "status", null: false
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "customer_credit_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "payment_date"
    t.decimal "current_debt", precision: 15, scale: 4, null: false
    t.index ["customer_credit_id"], name: "index_sim_customer_payments_on_customer_credit_id"
  end

  create_table "sim_funder_yields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "yield_number", null: false
    t.decimal "capital", precision: 15, scale: 4, null: false
    t.decimal "gross_yield", precision: 15, scale: 4, null: false
    t.decimal "isr", precision: 15, scale: 4, null: false
    t.decimal "net_yield", precision: 15, scale: 4, null: false
    t.decimal "total", precision: 15, scale: 4, null: false
    t.date "payment_date", null: false
    t.string "status", null: false
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "funder_id", null: false
    t.uuid "investment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "remaining_capital", precision: 15, scale: 4, null: false
    t.decimal "current_capital", precision: 15, scale: 4, null: false
    t.index ["funder_id"], name: "index_sim_funder_yields_on_funder_id"
    t.index ["investment_id"], name: "index_sim_funder_yields_on_investment_id"
  end

  create_table "states", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "country_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "state_key", null: false
    t.index ["country_id"], name: "index_states_on_country_id"
  end

  create_table "terms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "description", null: false
    t.integer "value", null: false
    t.string "term_type", null: false
    t.decimal "credit_limit", precision: 15, scale: 4, null: false
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "expires_at"
    t.uuid "user_id", null: false
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "my_app_id"
    t.index ["my_app_id"], name: "index_tokens_on_my_app_id"
    t.index ["user_id"], name: "index_tokens_on_user_id"
  end

  create_table "user_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "option_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["option_id"], name: "index_user_options_on_option_id"
    t.index ["user_id"], name: "index_user_options_on_user_id"
  end

  create_table "user_privileges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description", null: false
    t.string "value", null: false
    t.string "documentation"
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "key", null: false
    t.index ["user_id"], name: "index_user_privileges_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.string "name", default: "", null: false
    t.string "job"
    t.string "gender"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reset_password_token"
    t.uuid "role_id"
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "cities", "states"
  add_foreign_key "contributor_addresses", "contributors"
  add_foreign_key "contributor_addresses", "municipalities"
  add_foreign_key "contributor_addresses", "states"
  add_foreign_key "contributor_documents", "contributors"
  add_foreign_key "contributor_documents", "file_type_documents"
  add_foreign_key "contributors", "legal_entities"
  add_foreign_key "contributors", "people"
  add_foreign_key "customer_credits", "customers"
  add_foreign_key "customer_credits", "project_requests"
  add_foreign_key "customer_credits", "projects"
  add_foreign_key "customers", "contributors"
  add_foreign_key "customers", "file_types"
  add_foreign_key "customers", "users"
  add_foreign_key "documents", "ext_services"
  add_foreign_key "file_type_documents", "documents"
  add_foreign_key "file_type_documents", "file_types"
  add_foreign_key "funders", "contributors"
  add_foreign_key "funders", "file_types"
  add_foreign_key "funders", "users"
  add_foreign_key "funding_requests", "projects"
  add_foreign_key "investments", "funders"
  add_foreign_key "investments", "funding_requests"
  add_foreign_key "municipalities", "states"
  add_foreign_key "my_apps", "users"
  add_foreign_key "project_requests", "customers"
  add_foreign_key "project_requests", "payment_periods"
  add_foreign_key "project_requests", "terms"
  add_foreign_key "project_requests", "users"
  add_foreign_key "projects", "credit_ratings"
  add_foreign_key "projects", "customers"
  add_foreign_key "projects", "payment_periods"
  add_foreign_key "projects", "project_requests"
  add_foreign_key "projects", "terms"
  add_foreign_key "projects", "users"
  add_foreign_key "rates", "credit_ratings"
  add_foreign_key "rates", "payment_periods"
  add_foreign_key "rates", "terms"
  add_foreign_key "role_options", "options"
  add_foreign_key "role_options", "roles"
  add_foreign_key "sim_customer_payments", "customer_credits"
  add_foreign_key "sim_funder_yields", "funders"
  add_foreign_key "sim_funder_yields", "investments"
  add_foreign_key "states", "countries"
  add_foreign_key "tokens", "my_apps"
  add_foreign_key "tokens", "users"
  add_foreign_key "user_options", "options"
  add_foreign_key "user_options", "users"
  add_foreign_key "user_privileges", "users"
  add_foreign_key "users", "roles"
end
