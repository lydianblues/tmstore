# ActionMailer::Base.default_url_options[:host] = "mail.thirdmode.com"
# ActionMailer::Base.delivery_method = :smtp
# ActionMailer::Base.raise_delivery_errors = true
# ActionMailer::Base.smtp_settings = {
#   :address  => "mail.thirdmode.com",
#   :port  => 25, 
#   :domain => "thirdmode.com",
#  :user_name  => "mbs",
#  :password  => "ekim1126",
#  :authentication  => :login
# }

ActionMailer::Base.default_url_options[:host] = "localhost"

# Use the GMail SMTP server for now.
ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => 587,
  :domain => "thirdmode.com",
  :user_name => "lydianblues",
  :password => "zalogu53",
  :authentication => "plain",
  :enable_starttls_auto => true
}
