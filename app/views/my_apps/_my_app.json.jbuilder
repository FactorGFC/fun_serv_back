# frozen_string_literal: true

json.extract! my_app, :id, :user_id, :title, :app_id, :javascript_origins, :secret_key, :created_at, :updated_at
json.url my_app_url(my_app, format: :json)
