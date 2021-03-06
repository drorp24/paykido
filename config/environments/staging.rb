Paykido::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Environment
  config.hostname = 'paykido-staging.herokuapp.com'
  config.environment = 'staging'
  config.use_delayed_job = false
  config.use_proximo = true

  # Facebook (for server-side facebooker, make identical changes at facebooker.yml)
  config.app_id = '294773230578790'
  config.secret = '669dac0d2d3cded22cdead73526e87bd' 
  config.api_key = '294773230578790'

  # Policy
  config.send_sms = false
  config.rules_require_registration = true
  config.always_pay_manually = false
  config.offer_rule_or_registration_after = 1

  # G2S Integration
  config.ignore_g2s_status = true # change to false in production (redirects to g2s but completely ignores return status)
  config.skip_g2s = true   # change to false in production (skips payer redirection to g2s page, and payment if registered already)
  config.g2spp = 'http://91.220.189.4/lilippp/purchase.do'
  config.use_test_listener = true
  config.test_listener_base_uri = 'http://paykido-staging.herokuapp.com'
  config.test_listener_path     = '/g2s/TestPaykidoNotificationListener'
  config.redirect_after_registration = true
  config.listener_base_uri = 'http://91.220.189.4'
  config.listener_path     = '/lilippp/paykidoNotificationListener'
  config.listener_can_return_ordernotfound = true
  config.merchant_id = '5230109925932974239'
  config.merchant_site_id = '82371'
  config.secret_key = 'u5ITi630fQnjgyZiCcsLF77D63yoAJRbOsDvsvGxBtVGjYaXxwaDBUn2Fc6pqqJb' 
 config.return_secret_key = '0D1F95E18C5203E6AB1ADC68CC989543CA6B111D433A634B5AD76496F02FCC98'
 config.check_hash = true
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
  config.populate_test_fields = false  

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
  config.action_mailer.logger = nil
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { :host => 'paykido-staging.herokuapp.com'  }
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


  config.action_mailer.default_url_options = { :host => 'paykido-staging.herokuapp.com' }
  
  config.log_level = :debug

end
