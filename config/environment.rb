# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Paykido::Application.initialize!
Rails.logger = Le.new('aaf8d373-25c3-4620-bb20-c274d574f0b5', 'li482-241/Rails')
