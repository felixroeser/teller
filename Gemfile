source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '4.0.0'
gem 'i18n'

gem 'simple_config'

# Servers
gem 'puma'

# ORM
gem 'pg'
gem 'redis'
gem 'hiredis'

# Miscellanea
gem 'haml'
gem 'haml-rails', :group => :development
gem 'http_accept_language'
gem 'jquery-rails'
gem 'nokogiri'
gem 'simple_form', '~> 3.0.0.rc'
gem 'kaminari'
gem 'kaminari-bootstrap', git: 'https://github.com/mcasimir/kaminari-bootstrap.git'
gem 'http_accept_language'

gem 'httparty'

gem 'ruby-box'
gem 'twilio-ruby'

gem 'awesome_print'

gem 'devise', '~> 3.1.0'


# Sidekiq
gem 'sidekiq'
gem 'devise-async'
gem 'sidekiq-limit_fetch'
gem 'sinatra', require: false
gem 'slim'

# Video / pictures
gem 'mini_magick'
gem 'exifr'

gem 'clockwork' # https://github.com/tomykaira/clockwork

gem 'multi_json'

# Assets
gem 'coffee-rails', '~> 4.0.0'
gem 'haml_assets'
gem 'handlebars_assets', '~> 0.14.1'
gem 'i18n-js'
gem 'jquery-turbolinks'
gem 'less-rails'
gem 'sass-rails', '~> 4.0.0.rc2'
gem 'turbolinks'
gem 'anjlab-bootstrap-rails', '~> 3.0.0.2', require: 'bootstrap-rails', github: 'anjlab/bootstrap-rails'
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer'

group :development, :test do
  gem 'debugger-ruby_core_source', '~> 1.2.3'
  gem 'debugger'
  gem 'delorean'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-rails'
end

group :test do
  gem 'email_spec'
  gem 'launchy'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'webmock', require: false
end

group :staging, :production do
  gem 'rails_12factor'
end
