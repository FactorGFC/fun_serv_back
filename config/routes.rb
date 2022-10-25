# frozen_string_literal: true
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
# frozen_string_literal: true

Rails.application.routes.draw do
  get '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get '/my_apps', to: 'welcome#app', constraints: ->(solicitud) { !solicitud.session[:user_id].blank? }
  get '/', to: 'welcome#index'
  get '/', to: 'welcome#ok'
  get '/health_check', to: 'welcome#ok'
  post '/get_callback', to: 'sessions#get_callback'
  post '/get_callback_decline', to: 'sessions#get_callback_decline'
  post '/get_callback_token', to: 'sessions#get_callback_token'
  post '/get_comitee_callback_token', to: 'sessions#get_comitee_callback_token'
  get '/account_status_mailer/:id', to: 'sessions#send_account_status_mailer'
  get '/get_reset_pwd_token', to: 'sessions#get_reset_pwd_token'
  patch '/update_user_pwd', to: 'sessions#update_user'
  post '/customer_credit_signatory', to: 'sessions#signature'
  get '/terms', to: 'sessions#terms'
  get '/get_customer_credits', to: 'sessions#customer_credits'
  get '/get_credit_customer_report', to: 'sessions#get_credit_customer_report'
  get '/payment_periods', to: 'sessions#payment_periods'
  get '/ext_rates', to: 'sessions#ext_rates'
  get '/sim_customer_payments', to: 'sessions#sim_customer_payments'
  get '/contributor_documents', to: 'sessions#contributor_documents'
  get '/reports/customer_credit_id/:customer_credit_id/get_customer', to: 'sessions#get_customer' 
  #borrar al finalizar pruebas
  # root :to => 'welcome#index', as: :home

  resources :my_apps, except: %i[show index]
  resources :apidocs, only: [:index]
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :users do
        resources :user_privileges, except: %i[new edit]
      end
      resources :roles
      resources :options
      resources :role_options, only: %i[update destroy create]
      resources :user_options, only: %i[update destroy create]
      resources :lists
      resources :general_parameters
      resources :people
      resources :credit_bureaus
      resources :legal_entities
      resources :contributors do
        resources :contributor_addresses, except: %i[new edit]
        resources :customers, except: %i[new edit] 
        resources :contributor_documents, except: %i[new edit]
        resources :companies, except: %i[new edit]
      end
      resources :countries, only: %i[show index] do
        resources :states, only: %i[show index]
      end
      resources :states, only: %i[show index] do
        resources :cities
        resources :municipalities
      end
      resources :companies do
        resources :company_segments, except: %i[new edit]
      end
      resources :ext_services                  
      resources :file_types
      resources :documents
      resources :file_type_documents, only: %i[update destroy create]
      resources :terms
      resources :payment_periods
      resources :credit_ratings
      resources :rates
      resources :ext_rates
      resources :customer_personal_references
      resources :credit_analyses
      resources :payment_credits, only: %i[update destroy create]
      resources :payments
      resources :customer_credits_signatories


      resources :customer_credits do
        resources :sim_customer_payments, except: %i[new edit]
      end

      post 'credit_bureaus/get_credit_bureau_nip_validation', to: 'credit_bureaus#get_credit_bureau_nip_validation'
      post 'credit_bureaus/reset_credit_bureau_nip', to: 'credit_bureaus#reset_credit_bureau_nip'
      # Manda a traer el buro mediante moffin
      post 'credit_bureaus/traer_buro' => 'credit_bureaus#traer_buro', as: :traer_buro
      # Crea un archivo pdf con el resultado de moffin
      post '/credit_bureau_pdf'  => 'credit_bureaus#credit_bureau_pdf', as: :credit_bureau_pdf
      #get '/funding_requests/layout_base/:funding_request_id', to: 'funding_requests#funding_request_layout'
      #get '/funding_requests/company_id/:company_id/currency/:currency/funding_invoices', to: 'funding_requests#funding_invoices'                  
      #get '/funding_request_mailer/:id', to: 'funding_requests#funding_request_mailer'
      #get '/reports/get_request_used_date', to: 'reports#get_request_used_date'
      #get '/customer_credits/:customer_credit_id/total_payment/:total_payment/restructure_credit_term', to: 'restructure_credits#term'
      # post '/customer_credit_signatory/:signatory_token', to: 'customer_credits_signatories#signature'
      # put 'credit_bureau_info/:id' => 'customers#credit_bureau_info', as: :credit_bureau_info
      # put 'credit_bureau_report/:customer_id' => 'customers#credit_bureau_report', as: :credit_bureau_report

      get 'credit_bureau_report/:customer_id' => 'customers#credit_bureau_report', as: :credit_bureau_report


      get '/customer_credits_signatory/customer_credit_id', to: 'customer_credits_signatories#show_by_credit_id'
      #get '/user_registration', to: 'user_registration#create'
      post '/company_registration', to: 'company_registration#create'
      post '/user_registration', to: 'user_registration#create'
      patch '/user_update/update_user_info', to: 'user_update#update_user_info'
      get '/restructure_credit_term', to: 'restructure_credits#term'
      get '/restructure_credit_payment', to: 'restructure_credits#payment'
      get '/sim_credit', to: 'sim_customer_credits#sim_credit'
      get '/lists/domain/:domain', to: 'lists#domain', as: 'lists_domain_filter'      
      get '/postal_codes/pc/:pc', to: 'postal_codes#pc', as: 'postal_code_filter'
      get '/authenticate', to: 'api_sessions#create'
      get '/reset_password', to: 'api_sessions#reset_password'
      get '/get_reset_token', to: 'api_sessions#get_reset_token'
      get '/get_credit_customer_report', to: 'reports#get_credit_customer_report'
      get '/reports/start_date/:start_date/currency/:currency/layout_base/', to: 'reports#layout_base'
      get '/reports/job/:job/financial_workers', to: 'reports#financial_workers'
      get '/reports/user_id/:user_id/user_requests', to: 'reports#user_requests'
      get '/reports/user_id/:user_id/user_company', to: 'reports#user_company'
      get '/reports/user_id/:user_id/customer_user_association', to: 'reports#customer_user_association'
      get '/reports/get_company', to: 'reports#get_company'
      get '/reports/customer_credit_id/:customer_credit_id/get_customer', to: 'reports#get_customer' 
      get '/reports/user_id/:user_id/get_user_registration', to: 'reports#get_user_registration'
      get '/reports/user_id/:user_id/get_customer_pr', to: 'reports#get_customer_pr'   
      match '*unmatched', via: [:options], to: 'master_api#xhr_options_request'
      # get '/get_solicitud_credito', to: 'reports#get_credito'
      # get '/get_solicitud_credito', to: 'reports#get_solicitud_credito'
    end
  end
end
