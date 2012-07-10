Paykido::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # General
  config.hostname = 'paykido-beta.herokuapp.com'
  config.environment = 'edge'

  # Facebook (for server-side facebooker, make identical changes at facebooker.yml)
  config.app_id = '294773230578790'
  config.secret = '669dac0d2d3cded22cdead73526e87bd' 
  config.api_key = '294773230578790'

  # Policy
  config.send_sms = false
  config.rules_require_registration = false
  config.always_pay_manually = false

  # G2S Integration
  config.merchant_id = '136515662095334027'
  config.merchant_site_id = '79871'
  config.secret_key = 'lDovmOBmoHSCvCXxOSDNmJmjaKuTKcuFU767pi1p9yKXfVJb6FKquxrcVVMv7gh1' 
  config.version = '3.0.0'
  config.token_gateway = 'https://test.safecharge.com/service.asmx/Process?'
  config.sg_VendorID = '75381'
  config.sg_MerchantName = 'G2S - Paykido'
  config.sg_MerchantPhoneNumber = '972542343220'
  config.sg_WebSiteID = '79871'
  config.sg_ClientLoginID = 'G2STestExtTRX'
  config.sg_ClientPassword = 'Wf7s9a2VsR'
  config.sg_Descriptor = 'Paykido - safe payment for kids'
  config.sg_TransType = 'Sale' 
  config.referrer = 'localhost:3000/play'
  config.populate_test_fields = true  

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
#  config.cache_store = :mem_cache_store

  # Don't care if the mailer can't send
  #config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
#  config.logger = Logger.new(STDOUT)

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = true

  # Expands the lines which load the assets
  config.assets.debug = true
  
#  require 'tlsmail' #key but not always described
#  Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => 'paykido.com',
  :user_name            => 'welcome@paykido.com',
  :password             => 'dror160395',
  :authentication       => 'plain',
  :enable_starttls_auto => true  }
  
  ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :user_name            => "welcome@paykido.com",
    :password             => 'dror160395',
    :authentication       => "plain",
    :enable_starttls_auto => true
  }

end