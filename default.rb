# Default Fetch! Rails app
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

# Gems
# ==================================================
file 'Gemfile', <<-CODE
source 'https://rubygems.org'

# Core
gem 'rails', '4.1.1'
# Abort requests that are taking too long
gem 'rack-timeout'
# gem 'thread_safe', '~> 0.3'
gem 'mysql2'

# Assets
gem 'therubyracer', platforms: :ruby
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
# gem 'bower-rails'
# gem 'requirejs-rails'

# Forms made easy for Rails!
gem 'simple_form', git: 'https://github.com/plataformatec/simple_form'
# gem 'nested_form'
gem 'jbuilder', '~> 2.0'

# Auth
# gem 'devise'
# gem 'pundit'

# Markdown parser
# gem 'redcarpet'

# Uploads and attachments
# gem 'carrierwave', '~> 0.10'
# gem 'mini_magick', '~> 3.7'
# gem 'fog', '~> 1.22'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'spring'
  gem 'pry'
  gem 'debugger'
  gem 'foreman'
end

group :production do
  gem 'rails_12factor'
  gem 'puma'
end

group :test, :development do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'simplecov', '~> 0.7.1', require: false
  gem 'launchy'
  gem 'guard-rspec', require: false
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0'
end
CODE

# Install gems
run "bundle install"


# Install initializer for CarrierWave
# ==================================================
initializer 'carrierwave', <<-CODE
CarrierWave.configure do |config|
  config.cache_dir         = Rails.root.join('tmp/uploads')
  config.fog_credentials   = {
    provider:              'AWS',
    aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'] || '',
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] || '',
    region:                'eu-west-1',
    host:                  's3-eu-west-1.amazonaws.com'
  }
  config.fog_directory     = ENV['AWS_S3_BUCKET'] || "fapp-\#{Rails.env}"
  config.fog_public        = true
  config.fog_attributes    = { 'Cache-Control' => 'max-age=315576000',
                             'Expires' => 1.year.from_now.httpdate }

  config.storage           = Rails.env.production? ? :fog : :file
end
CODE

# Configure application for use with Foreman
# ==================================================
file 'Procfile', 'web: bundle exec puma -C ./config/puma.rb'

# Add configuration file for Puma
# ==================================================
file 'config/puma.rb', <<-CODE
#!/usr/bin/env puma
workers Integer(ENV['PUMA_WORKERS'] || 3)
threads Integer(ENV['MIN_THREADS']  || 1), Integer(ENV['MAX_THREADS'] || 16)

preload_app!

port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
CODE

# Install RSpec
# ==================================================
generate('rspec:install')

# Configure application
application <<-CODE
config.generators do |g|
      g.javascript_engine :js
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end
CODE

# Install SimpleForm
# ==================================================
generate('simple_form:install')

# Initialize guard
# ==================================================
run "bundle exec guard init rspec"

# Clean up Assets
# ==================================================
# Use SASS extension for application.css
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss"

# Remove the require_tree directives from the SASS and JavaScript files.
# It's better design to import or require things manually.
run "sed -i '' /require_tree/d app/assets/javascripts/application.js"
run "sed -i '' /require_tree/d app/assets/stylesheets/application.css.scss"

git add: "."
git commit: %Q{ -m 'Setup default gems' }