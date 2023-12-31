# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.6'

gem 'annotate'
gem 'awesome_print', require: 'ap'
gem 'bcrypt', '~> 3.1', '>= 3.1.11'
gem 'swagger-blocks'
gem 'rails', '~> 6.0.0'
gem 'pg', '1.2.3'
gem 'faker'
gem 'puma'
gem 'sass-rails', '~> 5'
gem 'webpacker', '= 5.1.1'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'materialize-sass'
gem 'omniauth-google-oauth2'
gem 'valid_email'
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'bootsnap', '1.4.3', require: false
gem 'rack-cors'
gem 'rest-client'
gem 'savon', '~> 2.0'
gem 'execjs', '2.7.0'
gem 'autoprefixer-rails', '~> 10.2', '>= 10.2.4.0'
gem 'mifiel'
gem 'combine_pdf'
gem 'nio4r', '2.5.3'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem "number_to_words"
# To make http request with ruby
gem 'httparty', '~> 0.16.4'
# Use Ransack search data
# gem 'ransack', '~> 2.6.0'
#gem 'prawn'
#gem 'ilovepdf'
gem 'rollbar'

gem 'aws-sdk', '~> 3'
gem 'aws-sdk-core' 

platforms :ruby do # linux
  gem 'unicorn'
end
platform :mswin, :mingw, :x64_mingw do
  gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
end

group :development, :test do
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 4.0.0.beta2'
end

group :development do
  gem 'rubocop', require: false
  gem 'web-console', '>= 3.3.0'
  gem 'capistrano', '3.4.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails-console'
  gem 'capistrano-sidekiq'
  gem 'rvm1-capistrano3', require: false
  gem 'airbrussh', require: false
end

group :test do
  gem 'shoulda-matchers'
end