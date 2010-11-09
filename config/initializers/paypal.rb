# We read the APP_CONFIG file ourselves to avoid imposing an order
# on the initializers.
raw_config = File.read(Rails.root.to_s + "/config/app_config.yml")
params = YAML.load(raw_config)[Rails.env].symbolize_keys

Paypal.setup do |config|
  config.api_mode = params[:paypal_api_mode]
  config.api_username = params[:paypal_api_username]
  config.api_password = params[:paypal_api_password]
  config.api_signature = params[:paypal_api_signature]
  config.api_secret = params[:paypal_api_secret]
  config.ipn_url = params[:paypal_ipn_url]
  config.return_url = params[:paypal_return_url]
  config.callback_url = params[:paypal_callback_url]
  config.cancel_url = params[:paypal_cancel_url]
end
