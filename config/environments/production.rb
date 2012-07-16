Paykido::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # General
  config.hostname = 'www.paykido.com'
  config.environment = 'beta'

  # Facebook (for server-side facebooker, make identical changes at facebooker.yml)
  config.app_id = '402586589783096'
  config.secret = '59791d5435202fe1f5eb69a872c0438a' 
  config.api_key = '402586589783096'

  # Policy
  config.send_sms = false
  config.rules_require_registration = true
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
  config.referrer = 'https://secure.gate2shop.com/ppp/purchase.do'   
  config.populate_test_fields = false  

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
   config.log_level = :debug
  # config.logger = Le.new('aaf8d373-25c3-4620-bb20-c274d574f0b5', 'li482-241/Rails')
  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  #config.assets.js_compressor  = :uglifier
  #config.assets.css_compressor = :scss
  
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { :host => 'www.paykido.com' }
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

  config.action_mailer.default_url_options = { :host => 'www.paykido.com' }

end
