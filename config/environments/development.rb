Store::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

 
  # Pasted from instructions after running "rails g devise:install"
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test
    paypal_options = {
      :login => "store_1233166355_biz_api1.thirdmode.com",
      :password => "1233166361",
      :signature => "ALZ2S3NXdLgg9g1ENcUy0awyGQAfAQk88a4VgQF0kt2yFDbnZ9SZjIAw"
    }
    ::STANDARD_GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(paypal_options)
  end

  config.to_prepare do
    BraintreeTransaction.gateway =
      ActiveMerchant::Billing::BraintreeGateway.new(
        :login    => 'testapi', # was demo
        :password => 'password1' # was password'
      )
  end

end
