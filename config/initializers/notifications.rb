ActiveSupport::Notifications.subscribe "paypal" do |name, start, finish, id, payload|
  Rails.logger.debug("PAYPAL: #{payload[:line]}")
end

