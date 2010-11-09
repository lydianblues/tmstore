Store::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Pasted from instructions after running "rails g devise:install"
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  config.active_support.deprecation = :log

  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test
    paypal_options = {
      :login => "store_1233166355_biz_api1.thirdmode.com",
      :password => "1233166361",
      :signature => "ALZ2S3NXdLgg9g1ENcUy0awyGQAfAQk88a4VgQF0kt2yFDbnZ9SZjIAw"
    }
    ::STANDARD_GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(paypal_options)
  end

  ::PAYPAL_IPN_HANDLER = Paypal::Notify.new
  ::PAYPAL_GATEWAY = Paypal::Gateway.new

  config.to_prepare do
    BraintreeTransaction.gateway =
      ActiveMerchant::Billing::BraintreeGateway.new(
        :login    => 'testapi', # was demo
        :password => 'password1' # was password'
      )
  end

end
