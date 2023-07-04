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

ActiveRecord::Schema.define(version: 2023_07_03_172137) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "cities", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "state_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "companies", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "business_name", null: false
    t.date "start_date", null: false
    t.decimal "credit_limit", precision: 15, scale: 4
    t.decimal "credit_available", precision: 15, scale: 4
    t.decimal "balance", precision: 15, scale: 4
    t.string "document"
    t.string "sector"
    t.string "subsector"
    t.string "company_rate"
    t.uuid "contributor_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["contributor_id"], name: "index_companies_on_contributor_id"
  end

  create_table "company_segments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.decimal "company_rate", precision: 15, scale: 4, null: false
    t.decimal "credit_limit", precision: 15, scale: 4, null: false
    t.decimal "max_period", precision: 15, scale: 4, null: false
    t.decimal "commission", precision: 15, scale: 4
    t.string "currency"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_company_segments_on_company_id"
  end

  create_table "contributor_addresses", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "contributor_documents", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "contributors", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "contributor_type", null: false
    t.string "bank"
    t.string "account_number"
    t.string "clabe"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "person_id"
    t.uuid "legal_entity_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["legal_entity_id"], name: "index_contributors_on_legal_entity_id"
    t.index ["person_id"], name: "index_contributors_on_person_id"
  end

  create_table "countries", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "sortname", null: false
    t.string "name", null: false
    t.integer "phonecode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "credit_analyses", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "debt_rate", precision: 15, scale: 4
    t.decimal "cash_flow", precision: 15, scale: 4
    t.string "credit_status", null: false
    t.string "previus_credit"
    t.decimal "discounts", precision: 15, scale: 4
    t.decimal "debt_horizon", precision: 15, scale: 4
    t.date "report_date", null: false
    t.string "mop_key", null: false
    t.decimal "last_key", precision: 15, scale: 4, null: false
    t.string "balance_due"
    t.decimal "payment_capacity", precision: 15, scale: 4
    t.decimal "lowest_key", precision: 15, scale: 4, null: false
    t.decimal "departamental_credit", precision: 15, scale: 4
    t.decimal "car_credit", precision: 15, scale: 4
    t.decimal "mortagage_loan", precision: 15, scale: 4
    t.decimal "other_credits", precision: 15, scale: 4
    t.decimal "accured_liabilities", precision: 15, scale: 4
    t.decimal "debt", precision: 15, scale: 4
    t.decimal "net_flow", precision: 15, scale: 4
    t.uuid "customer_credit_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "total_amount", precision: 15, scale: 4
    t.string "credit_type"
    t.string "customer_number"
    t.decimal "anual_rate", precision: 15, scale: 4
    t.decimal "total_cost", precision: 15, scale: 4
    t.decimal "overall_rate", precision: 15, scale: 4
    t.decimal "total_debt", precision: 15, scale: 4
    t.decimal "total_income", precision: 15, scale: 4
    t.decimal "total_expenses", precision: 15, scale: 4
    t.decimal "monthly_income", precision: 15, scale: 4
    t.decimal "monthly_expenses", precision: 15, scale: 4
    t.decimal "payment_credit_cp", precision: 15, scale: 4
    t.decimal "payment_credit_lp", precision: 15, scale: 4
    t.decimal "debt_cp", precision: 15, scale: 4
    t.decimal "departamentalc_debt", precision: 15, scale: 4
    t.decimal "personalc_debt", precision: 15, scale: 4
    t.decimal "car_debt", precision: 15, scale: 4
    t.decimal "mortagage_debt", precision: 15, scale: 4
    t.decimal "otherc_debt", precision: 15, scale: 4
    t.index ["customer_credit_id"], name: "index_credit_analyses_on_customer_credit_id"
  end

  create_table "credit_bureaus", force: :cascade do |t|
    t.uuid "customer_id", null: false
    t.integer "bureau_id"
    t.jsonb "bureau_info"
    t.jsonb "bureau_report"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.index ["customer_id"], name: "index_credit_bureaus_on_customer_id"
  end

  create_table "credit_ratings", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "customer_credits", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "total_requested", precision: 15, scale: 4, null: false
    t.decimal "capital", precision: 15, scale: 4, null: false
    t.decimal "interests", precision: 15, scale: 4, null: false
    t.decimal "iva", precision: 15, scale: 4, null: false
    t.decimal "total_debt", precision: 15, scale: 4, null: false
    t.decimal "total_payments", precision: 15, scale: 4, null: false
    t.decimal "balance", precision: 15, scale: 4, null: false
    t.decimal "fixed_payment", precision: 15, scale: 4, null: false
    t.string "status", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "restructure_term"
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "customer_id", null: false
    t.uuid "payment_period_id"
    t.uuid "term_id"
    t.uuid "credit_rating_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "rate", null: false
    t.decimal "debt_time", precision: 15, scale: 4
    t.string "destination"
    t.decimal "amount_allowed", precision: 15, scale: 4
    t.decimal "time_allowed", precision: 15, scale: 4
    t.decimal "iva_percent", precision: 15, scale: 4
    t.string "credit_folio"
    t.string "currency"
    t.uuid "user_id"
    t.decimal "insurance1", precision: 15, scale: 4
    t.decimal "commission1", precision: 15, scale: 4
    t.string "credit_number"
    t.index ["credit_rating_id"], name: "index_customer_credits_on_credit_rating_id"
    t.index ["customer_id"], name: "index_customer_credits_on_customer_id"
    t.index ["payment_period_id"], name: "index_customer_credits_on_payment_period_id"
    t.index ["term_id"], name: "index_customer_credits_on_term_id"
    t.index ["user_id"], name: "index_customer_credits_on_user_id"
  end

  create_table "customer_credits_signatories", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "signatory_token"
    t.datetime "signatory_token_expiration"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "notes"
    t.uuid "user_id", null: false
    t.uuid "customer_credit_id", null: false
    t.index ["customer_credit_id"], name: "index_customer_credits_signatories_on_customer_credit_id"
    t.index ["user_id"], name: "index_customer_credits_signatories_on_user_id"
  end

  create_table "customer_personal_references", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "second_last_name", null: false
    t.string "address"
    t.string "phone"
    t.string "reference_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "customer_id", null: false
    t.index ["customer_id"], name: "index_customer_personal_references_on_customer_id"
  end

  create_table "customers", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.decimal "salary", precision: 15, scale: 4, null: false
    t.string "salary_period", null: false
    t.string "customer_type", null: false
    t.string "status", null: false
    t.decimal "other_income", precision: 15, scale: 4
    t.decimal "net_expenses", precision: 15, scale: 4
    t.decimal "family_expenses", precision: 15, scale: 4
    t.decimal "house_rent", precision: 15, scale: 4
    t.decimal "credit_cp", precision: 15, scale: 4
    t.decimal "credit_lp", precision: 15, scale: 4
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "contributor_id", null: false
    t.uuid "user_id"
    t.uuid "file_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "immediate_superior"
    t.decimal "seniority", precision: 15, scale: 4
    t.decimal "ontime_bonus", precision: 15, scale: 4
    t.decimal "assist_bonus", precision: 15, scale: 4
    t.decimal "food_vouchers", precision: 15, scale: 4
    t.decimal "total_income", precision: 15, scale: 4
    t.decimal "total_savings_found", precision: 15, scale: 4
    t.decimal "christmas_bonus", precision: 15, scale: 4
    t.decimal "taxes", precision: 15, scale: 4
    t.decimal "imms", precision: 15, scale: 4
    t.decimal "savings_found", precision: 15, scale: 4
    t.decimal "savings_found_loand", precision: 15, scale: 4
    t.decimal "savings_bank", precision: 15, scale: 4
    t.decimal "insurance_discount", precision: 15, scale: 4
    t.decimal "child_support", precision: 15, scale: 4
    t.decimal "extra_expenses", precision: 15, scale: 4
    t.decimal "infonavit", precision: 15, scale: 4
    t.uuid "company_id"
    t.string "job"
    t.string "public_charge"
    t.string "public_charge_det"
    t.string "relative_charge"
    t.string "benefit"
    t.string "benefit_detail"
    t.string "responsible"
    t.string "responsible_detail"
    t.string "relative_charge_det"
    t.string "other_income_detail"
    t.string "file_token"
    t.string "file_token_expiration"
    t.index ["company_id"], name: "index_customers_on_company_id"
    t.index ["contributor_id"], name: "index_customers_on_contributor_id"
    t.index ["file_type_id"], name: "index_customers_on_file_type_id"
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "documents", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "empleados_alsuper", id: false, comment: "lista de empleados de alsuper proporcionada", force: :cascade do |t|
    t.string "nombre", comment: "Nombre del empleado"
    t.string "primer_apellido"
    t.string "segundo_apellido"
    t.string "banco"
    t.string "clabe"
    t.string "cla_trab"
    t.string "cla_depto"
    t.string "departamento"
    t.string "cla_area"
    t.string "area"
    t.string "cla_puesto"
    t.string "puesto"
    t.string "noafiliacion"
    t.string "rfc"
    t.string "curp"
    t.string "tarjeta"
    t.string "tipo_puesto"
    t.string "fecha_ingreso"
    t.string "categoria"
  end

  create_table "ext_rates", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "description", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.decimal "value", precision: 15, scale: 4, null: false
    t.string "rate_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "max_value", precision: 15, scale: 4
  end

  create_table "ext_services", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "file_type_documents", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "file_types", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.string "customer_type"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "general_parameters", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "legal_entities", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "listado_alsupers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nombre", default: "", null: false
    t.string "primer_apellido", default: "", null: false
    t.string "segundo_apellido"
    t.string "banco"
    t.string "clabe"
    t.string "cla_trab"
    t.string "cla_depto"
    t.string "departamento"
    t.string "cla_area"
    t.string "area"
    t.string "cla_puesto"
    t.string "puesto"
    t.string "noafiliacion", default: "", null: false
    t.string "rfc", default: "", null: false
    t.string "curp", default: "", null: false
    t.string "tarjeta"
    t.string "tipo_puesto"
    t.string "fecha_ingreso"
    t.uuid "customer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "categoria"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.index ["customer_id"], name: "index_listado_alsupers_on_customer_id"
  end

  create_table "lists", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "domain", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["domain", "key"], name: "index_lists_on_domain_and_key", unique: true
  end

  create_table "municipalities", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "municipality_key", null: false
    t.string "name", null: false
    t.uuid "state_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["state_id"], name: "index_municipalities_on_state_id"
  end

  create_table "my_apps", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "title"
    t.string "app_id"
    t.string "javascript_origins"
    t.string "secret_key"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_my_apps_on_user_id"
  end

  create_table "options", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.string "group"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "payment_credits", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "pc_type", null: false
    t.decimal "total", precision: 15, scale: 4, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "payment_id", null: false
    t.uuid "customer_credit_id", null: false
    t.index ["customer_credit_id"], name: "index_payment_credits_on_customer_credit_id"
    t.index ["payment_id"], name: "index_payment_credits_on_payment_id"
  end

  create_table "payment_periods", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "payments", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "payment_date", null: false
    t.string "payment_type", null: false
    t.string "payment_number", null: false
    t.string "currency", null: false
    t.decimal "amount", precision: 15, scale: 4, null: false
    t.string "email_cfdi", null: false
    t.string "notes"
    t.string "voucher"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "contributor_from_id", null: false
    t.uuid "contributor_to_id", null: false
    t.index ["contributor_from_id"], name: "index_payments_on_contributor_from_id"
    t.index ["contributor_to_id"], name: "index_payments_on_contributor_to_id"
  end

  create_table "people", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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
    t.string "martial_regime"
    t.integer "minior_dependents"
    t.integer "senior_dependents"
    t.string "housing_type"
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

  create_table "postal_codes", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.integer "pc", null: false
    t.string "suburb_type"
    t.string "suburb", null: false
    t.string "municipality", null: false
    t.string "state", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pc"], name: "index_postal_codes_on_pc"
  end

  create_table "rates", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "description", null: false
    t.string "value", null: false
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "term_id"
    t.uuid "payment_period_id"
    t.uuid "credit_rating_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credit_rating_id"], name: "index_rates_on_credit_rating_id"
    t.index ["payment_period_id"], name: "index_rates_on_payment_period_id"
    t.index ["term_id"], name: "index_rates_on_term_id"
  end

  create_table "role_options", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "role_id", null: false
    t.uuid "option_id", null: false
    t.index ["option_id"], name: "index_role_options_on_option_id"
    t.index ["role_id"], name: "index_role_options_on_role_id"
  end

  create_table "roles", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sim_customer_payments", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.integer "pay_number", null: false
    t.decimal "current_debt", precision: 15, scale: 4, null: false
    t.decimal "remaining_debt", precision: 15, scale: 4, null: false
    t.decimal "payment", precision: 15, scale: 4, null: false
    t.decimal "capital", precision: 15, scale: 4, null: false
    t.decimal "interests", precision: 15, scale: 4, null: false
    t.decimal "iva", precision: 15, scale: 4, null: false
    t.date "payment_date", null: false
    t.string "status", null: false
    t.string "attached"
    t.string "extra1"
    t.string "extra2"
    t.string "extra3"
    t.uuid "customer_credit_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "insurance", precision: 15, scale: 4
    t.decimal "commission", precision: 15, scale: 4
    t.decimal "aditional_payment", precision: 15, scale: 4
    t.index ["customer_credit_id"], name: "index_sim_customer_payments_on_customer_credit_id"
  end

  create_table "states", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "state_key", null: false
    t.uuid "country_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_id"], name: "index_states_on_country_id"
  end

  create_table "terms", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "tokens", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "expires_at"
    t.uuid "user_id", null: false
    t.uuid "my_app_id"
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["my_app_id"], name: "index_tokens_on_my_app_id"
    t.index ["user_id"], name: "index_tokens_on_user_id"
  end

  create_table "user_options", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "option_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["option_id"], name: "index_user_options_on_option_id"
    t.index ["user_id"], name: "index_user_options_on_user_id"
  end

  create_table "user_privileges", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "description", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.string "documentation"
    t.uuid "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_privileges_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.string "name", default: "", null: false
    t.string "job"
    t.string "gender"
    t.string "status"
    t.string "reset_password_token"
    t.uuid "role_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "company_id"
    t.string "company_signatory"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "cities", "states"
  add_foreign_key "companies", "contributors"
  add_foreign_key "company_segments", "companies"
  add_foreign_key "contributor_addresses", "contributors"
  add_foreign_key "contributor_addresses", "municipalities"
  add_foreign_key "contributor_addresses", "states"
  add_foreign_key "contributor_documents", "contributors"
  add_foreign_key "contributor_documents", "file_type_documents"
  add_foreign_key "contributors", "legal_entities"
  add_foreign_key "contributors", "people"
  add_foreign_key "credit_analyses", "customer_credits"
  add_foreign_key "credit_bureaus", "customers"
  add_foreign_key "customer_credits", "credit_ratings"
  add_foreign_key "customer_credits", "customers"
  add_foreign_key "customer_credits", "payment_periods"
  add_foreign_key "customer_credits", "terms"
  add_foreign_key "customer_credits", "users"
  add_foreign_key "customer_credits_signatories", "customer_credits"
  add_foreign_key "customer_credits_signatories", "users"
  add_foreign_key "customer_personal_references", "customers"
  add_foreign_key "customers", "companies"
  add_foreign_key "customers", "contributors"
  add_foreign_key "customers", "file_types"
  add_foreign_key "customers", "users"
  add_foreign_key "documents", "ext_services"
  add_foreign_key "file_type_documents", "documents"
  add_foreign_key "file_type_documents", "file_types"
  add_foreign_key "listado_alsupers", "customers"
  add_foreign_key "municipalities", "states"
  add_foreign_key "my_apps", "users"
  add_foreign_key "payment_credits", "customer_credits"
  add_foreign_key "payment_credits", "payments"
  add_foreign_key "payments", "contributors", column: "contributor_from_id"
  add_foreign_key "payments", "contributors", column: "contributor_to_id"
  add_foreign_key "rates", "credit_ratings"
  add_foreign_key "rates", "payment_periods"
  add_foreign_key "rates", "terms"
  add_foreign_key "role_options", "options"
  add_foreign_key "role_options", "roles"
  add_foreign_key "sim_customer_payments", "customer_credits"
  add_foreign_key "states", "countries"
  add_foreign_key "tokens", "my_apps"
  add_foreign_key "tokens", "users"
  add_foreign_key "user_options", "options"
  add_foreign_key "user_options", "users"
  add_foreign_key "user_privileges", "users"
  add_foreign_key "users", "companies"
  add_foreign_key "users", "roles"
end
