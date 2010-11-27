class PaypalTransaction < ActiveRecord::Base

  belongs_to :order
  serialize :ipn_params, Hash
  serialize :details_params, Hash

  scope :latest, order("timestamp DESC").limit(1)

  #################### Paypal API functions #################

  def self.capture(order, final, cents)
    opts = { }
    if final
      opts[:complete_type] = "Complete"
      action = "final capture"
    else
      opts[:complete_type] = "NotComplete"
      action = "partial capture"
    end

    # Find the most recent PayPal transaction for this order.  Use its
    # authorization ID, if it has one, otherwise use its transaction id.
    trans = order.paypal_transactions.latest[0]
    #raise trans.to_yaml
    auth_id = trans.auth_id || trans.txn_id
    opts[:authorization_id] = auth_id
    opts[:amount] = MoneyUtils.format_for_paypal(cents)
    response = PAYPAL_GATEWAY.do_capture(opts)
    paypal_params = response.paypal_params

    if response.success?
      # Create a new paypal_transaction record in the database.
      trans = order.paypal_transactions.create(
        :action => action,
        :amount => cents,
        :status => "OK",
        :timestamp => paypal_params[:TIMESTAMP],
        :txn_id =>  paypal_params[:TRANSACTIONID],
        :auth_id => paypal_params[:AUTHORIZATIONID],
        :parent_txn_id => paypal_params[:PARENTTRANSACTIONID],
        :txn_type => paypal_params[:TRANSACTIONTYPE],
        :payment_type => paypal_params[:PAYMENTTYPE],
        :transaction_fee => paypal_params[:FEEAMT],
        :sales_tax => paypal_params[:TAXAMT],
        :currency_code => paypal_params[:CURRENCYCODE],
        :payment_status => paypal_params[:PAYMENTSTATUS])
    else
      trans = order.paypal_transactions.create(
        :action => action,
        :txn_id =>  paypal_params[:TRANSACTIONID],
        :amount => cents,
        :status => "Fail",
        # :message => response.message,
        :timestamp => paypal_params[:TIMESTAMP])
    end
    response
  end

  def self.void(order)
    opts = { }
    trans = order.paypal_transactions.latest[0]
    auth_id = trans.auth_id || trans.txn_id
    opts[:authorization_id] = auth_id
    response = PAYPAL_GATEWAY.do_void(opts)
    paypal_params = response.paypal_params
    attrs = { 
      :action => "void",
      :txn_id =>  paypal_params[:TRANSACTIONID],
      :timestamp => paypal_params[:TIMESTAMP]
    }
    if response.success?
      attrs[:status] = "OK"
    else
      attrs[:status] = "Fail"
    end
    order.paypal_transactions.create(attrs)
    response
  end

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

