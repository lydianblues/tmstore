PAYPAL_CERT_PEM = File.read("#{Rails.root}/security/paypal.crt")
APP_CERT_PEM = File.read("#{Rails.root}/security/thirdmode.crt")
APP_KEY_PEM = File.read("#{Rails.root}/security/thirdmode.key")