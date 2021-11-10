# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', github: "rails/rails", branch: "main" # '~> 6.1.3', '>= 6.1.3.1'
# Use sqlite3 as the database for Active Record
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
# gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'
#
gem 'devise', github: "heartcombo/devise", branch: "main"
gem 'irb'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  gem "rails-erd"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem "annotate", "~> 3.1"
  gem 'mini_racer', platforms: :ruby
  gem 'rubocop', '~> 1.17'
  gem 'rubocop-rails', '~> 2.10'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'cancancan', '~> 3.2'

gem 'rolify', '~> 6.0', git: 'https://github.com/adzienis/rolify', branch: "master"

gem 'turbo-rails', github: "hotwired/turbo-rails", ref: "31e19cb4b781d186bc31edaa4035b2e13a19fc3c"

gem 'pg', '~> 1.2'

gem 'pagy'

gem 'simple_form', '~> 5.1'

gem 'pghero', '~> 2.8'

gem 'grape', '~> 1.5'

gem 'grape-swagger', '~> 1.4'

gem 'doorkeeper', '~> 5.5'

gem "discard", "~> 1.2"

gem "doorkeeper-i18n", "~> 5.2"

gem "noticed", "~> 1.4"

gem "sidekiq", "~> 6.2"

gem "whenever", "~> 1.0"

gem "responders", "~> 3.0", github: 'heartcombo/responders'

gem "anycable-rails", "~> 1.1"

gem "jsbundling-rails", "~> 0.1.9"

gem "cssbundling-rails", "~> 0.2.4"

gem "newrelic_rpm", "~> 8.0"

gem "jwt", "~> 2.2"

gem "http", "~> 5.0"

gem "pry", "~> 0.14.1"

gem "rack-cors", "~> 1.1"

gem "searchkick", "~> 4.6"

gem "view_component", "~> 2.41", require: "view_component/engine"
gem "anyway_config", "~> 2.2"

gem "httparty", "~> 0.20.0"

gem "chartkick", "~> 4.1"

gem "groupdate", "~> 5.2"
gem "pretender", "~> 0.3.4"
