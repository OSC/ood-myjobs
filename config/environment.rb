# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Load the dashboard specific configuration.
require File.expand_path('../configuration', __FILE__)

# Include custom initializers
Rails.application.configure do |config|
  config.paths["config/initializers"] << Configuration.config_root.join("initializers").to_s
end

# Initialize the Rails application.
Rails.application.initialize!
