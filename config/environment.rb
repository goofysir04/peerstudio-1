# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Humanmachine::Application.initialize!

# You also need to explicitly enable OAuth 1 support in the environment.rb or an initializer:
OAUTH_10_SUPPORT = true

