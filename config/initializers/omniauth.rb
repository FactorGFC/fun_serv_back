# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '1049295052065-oob17b7lfio46vhm7uce3fus8a8lbm9b.apps.googleusercontent.com', '2vMeaU57OrhYwXJdPcnYJMly'
end
