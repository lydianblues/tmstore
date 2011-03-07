class PaypalTransaction < ActiveRecord::Base

  belongs_to :order
  serialize :ipn_params, Hash
  serialize :details_params, Hash

  scope :latest, order("timestamp DESC").limit(1)

  private

  # Called during IPN processing. Should be called only from HTTPS.
  #
  # From PayPal's "Instant Payment Notification Guide":
  #
  # "The IPN message service should not be considered a real-time service. Your
  # checkout flow should not wait on an IPN message before it is allowed to
  # complete. If your website waits for an IPN message, checkout processing may
  # be delayed due to system load and become more complicated because of the
  # possibility of retries."
  #
  # From "Website Payments Standard Guide":
  #
  #  "You can use IPN with other notification mechanisms. For example, you can
  #  use PDT (Payment Data Transfer) or the API to determine real-time
  #  information about a transaction and let IPN notify you of any changes
  #  after the transaction occurs."
  #
  # Therefore, maybe we should use PDT and not IPN to mark the cart as purchased.
  #
  def purchase(params)

    raise params.to_yaml

    order = self.order
    logger.info "IPN 1"
    return unless order && params
    logger.info "IPN 2"

    if params && params[:action] == 'notify' &&
      params[:payment_status] == 'Completed' &&
      params[:secret] == APP_CONFIG[:paypal_secret] # &&
      # params[:mc_gross] == order.total_price.to_s && params[:mc_currency] == "USD"

      logger.info "IPN 4"

      Order.create_shipping_address(
        params.merge({:address_type => "shipping"}))
      self.update_attributes(
         params.merge({:params => params, :action => "notify"}))
      order.update_attribute(:purchased_at, Time.now)
    end
  end

  # For PayPal Standard only.
  def void_order(order)
  end

end

