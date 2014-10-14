source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Use sqlite3 as the database for Active Record
# gem 'sqlite3', group: :development

# gem 'debugger', group: :development

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', :git => 'https://github.com/chinmayk/turbolinks'
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

#templates
gem "therubyracer"
gem "less-rails", '2.3.3'
# gem "twitter-bootstrap-rails"
gem 'bootstrap-datetimepicker-rails'

#for editor
gem 'rails-bootstrap-markdown'

# User Authentication and Authorization
gem "devise"
gem "omniauth"
gem 'omniauth-openid', :git => 'https://github.com/intridea/omniauth-openid.git'
gem "cancan"

gem "mysql2", group: :production
gem "pg", group: :development #only heroku
gem 'rails_12factor', group: :production #only heroku
#create views
# gem "schema_plus"

gem 'google-analytics-rails'


# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
group :development do
	gem 'capistrano-bundler', '>= 1.1.0'
 	gem 'capistrano',  '~> 3.2'
	gem 'capistrano-rails', '~> 1.1'
	# gem 'capistrano-rvm'
end

#For server/config
gem 'thin'
gem 'figaro'
# gem 'sqlite3' #just for testing

gem 'delayed_job_active_record'
gem 'daemons'

gem "validates_email_format_of" # Validate email addresses

#To impersonate users
gem 'pretender'

gem 'airbrake'

#For editor and uploads
gem "paperclip"
# gem "ckeditor", :github => "galetahub/ckeditor"
gem "aws-sdk", '~>1.42'
# gem 's3_direct_upload', :git => "https://github.com/waynehoover/s3_direct_upload.git" # direct upload (CORS) form helper and assets


# gem 'rmagick', '2.13.2'

#For heroku testing
gem "unicorn"

#for editor
gem "redcarpet"

gem 'will_paginate', '~> 3.0'


#For versioning in submissions
gem 'acts-as-taggable-on'

#For easy nested forms
gem 'nested_form'

# gem 'newrelic_rpm'
gem 'whenever', :require => false


gem 'ims-lti' , :git => "https://github.com/chinmayk/ims-lti" #, path: "~/projects/ims-lti" #
gem 'activerecord-session_store'

#for pushing grades to coursera
# gem "always_verify_ssl_certificates"

# gem "client_side_validations"

# Use debugger
# gem 'debugger', group: [:development, :test]

#vineet
gem 'hirb', group: [:development, :test]
