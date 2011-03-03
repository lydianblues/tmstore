Store::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  config.active_support.deprecation = :log # or :stderr

=begin

  # Bogus Test Environment

  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test
    ::STANDARD_GATEWAY = ActiveMerchant::Billing::BogusGateway.new
    ::EXPRESS_GATEWAY = ActiveMerchant::Billing::BogusGateway.new
  end

  config.to_prepare do
    BraintreeTransaction.gateway =
       ActiveMerchant::Billing::BogusGateway.new
  end

=end

  # Merchant Test Environment

  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test
    paypal_options = { # XXX-PayPal this should be in app_config.yml
      :login => "store_1233166355_biz_api1.thirdmode.com",
      :password => "1233166361",
      :signature => "ALZ2S3NXdLgg9g1ENcUy0awyGQAfAQk88a4VgQF0kt2yFDbnZ9SZjIAw"
    }
  end

  config.to_prepare do
    BraintreeTransaction.gateway = 
      ActiveMerchant::Billing::BraintreeGateway.new(
        :login    => 'testapi', # was demo
        :password => 'password1' # was password'
      )
  end

end
