class PaypalTransaction < ActiveRecord::Base

  belongs_to :order
  serialize :ipn_params, Hash
  serialize :details_params, Hash

  scope :latest, order("timestamp DESC").limit(1)

  ################## Begin PayPal Express ###############

  # PayPal SetExpressCheckout API.
  #
  # PaypalExpressController#setup just created the transaction and linked it to
  # the current order.  The only field it initialized is the IP address of the
  # buyer.
  def setup_purchase(options)
    order.update_attribute :payment_method, "PayPal Express"

    # We have to commit to this cart before we tell PayPal about the cart.
    order.freeze!

    response = PAYPAL_GATEWAY.set_express_checkout(options.merge(
      :amount => MoneyUtils.format_for_paypal(order.price_in_cents),
      :invoice_number => order.invoice_number, :custom => String(self.id)))
    if response.success?
      order.prepare!
      update_attributes(:token => response.token, :action => 'setup')
    else
      # stay in the frozen state
      logger.warn("set_express_checkout failed, txn_id = #{options.txn_id}, " +
                  "invoice = #{order.invoice_number}")
    end
    response
  end

  # PayPal GetExpressCheckoutDetails API.
  def details_for(user)
    response = PAYPAL_GATEWAY.get_express_checkout_details(:token => token)

    logger.info "============== GetExpressCheckoutDetails ===================="
    logger.info response.to_yaml

    unless response.success?
      logger.warn("details_for failed, token = #{token}, " +
                  "invoice = #{order.invoice_number}")
    else
      order_params = response.order_params
      if Integer(order_params[:invoice_number]) != order.invoice_number
        logger.warn("Mismatched invoice numbers: order invoice number = " +
                    "#{order.invoice_number} and params invoice number = " +
                    "#{order_params[:invoice_number]}")
      else
        # Update the shipping address.
        address_params = response.address_params
        if address_params[:country] == "United States"
          address_params[:state] =
            USStates.abbrev_to_name(address_params[:state])
        end
        order.create_or_update_shipping_address(user, address_params)

        # Update the order parameters.
        order_params.delete(:invoice_number)
        order.update_attributes(order_params)

        # Update the transaction.
        update_attributes(
          :test => PAYPAL_GATEWAY.test_mode?,
          :action => 'details',
          :payer_id => response.paypal_params[:PAYERID],
          :details_params => response.paypal_params)
      end
    end
    response
  end

  # PayPal DoExpressCheckoutPayment
  # Use :payment_action => "Authorization" in options to authorize, otherwise
  # transaction is a sale.
  def express_payment(options = {})
    amount = MoneyUtils.format_for_paypal(order.price_in_cents)
    payment_action = APP_CONFIG[:paypal_express_payment_action]
    
    response = PAYPAL_GATEWAY.do_express_checkout_payment(
      {:amount => amount, :payment_action => payment_action,
       :payer_id => self.payer_id }.merge(options))

    if payment_action == "Authorization"
      action = "authorization"
    else payment_action == "Sale"
      action = "sale"
    end

    logger.info "================ DoExpressCheckoutPayment ======================"
    logger.info response.to_yaml

    if response.success?
      attrs = response.paypal_params
      payment_status = attrs[:PAYMENTSTATUS]

      # Record the attributes for the transaction.
      update_attributes(
        :action => action,
        :status => "OK",
        :amount => order.price_in_cents,
        :payment_status => payment_status,
        :txn_id => attrs[:TRANSACTIONID],
        :txn_type => attrs[:TRANSACTIONTYPE],
        :payment_type => attrs[:PAYMENTTYPE],
        :timestamp => DateTime.parse(attrs[:TIMESTAMP]))

      order_attrs = { 
        :purchased_at => Time.now,
        :memo => attrs[:NOTE],
        :pending_reason => attrs[:PENDINGREASON],
      }

      if payment_action == "Authorization"
        order_attrs[:total_captured] = 0
        order_attrs[:amount_authorized] = order.price_in_cents
      end

      case payment_status
      when "Completed"
        fee = MoneyUtils.paypal_to_cents(attrs[:FEEAMT])
        order.update_attributes(order_attrs.merge(
          :status => "Purchased", :transaction_fee => fee))
        order.complete!
      when "Pending"
        if attrs[:PENDINGREASON] == "authorization"
          order.authorize!
          order.update_attributes(order_attrs.merge(:status => "Authorized"))
        else
          order.wait_for_review!
          order.update_attributes(order_attrs.merge(:status => "Pending Review"))
        end
      else
        logger.warn "Express Checkout Payment: " + 
          "unhandled payment status: #{payment_status}"
      end
    else
      logger.warn "Express Checkout Payment API call Failed"
    end
    response
  end

  def cancel(options)
    update_attributes(
      :action => "cancel")
    order.cancel!
  end

  def redirect_url_for(token)
    PAYPAL_GATEWAY.redirect_url_for(token)
  end

  ####################  End PayPal Express ##################

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

  # "payment_action" can be "authorization" or "sale"
  def self.encrypt_order(order, payment_action = "sale")

    ipn_url_with_secret = APP_CONFIG[:paypal_ipn_url] + 
      "?secret=#{APP_CONFIG[:paypal_api_secret]}"

    values = {:cmd => '_cart',
              :upload => 1,
              :test_ipn => APP_CONFIG[:paypal_test_ipn],
              :business => APP_CONFIG[:paypal_business],
              :cert_id => APP_CONFIG[:paypal_cert_id],
              :custom => "PayPal",
              :invoice => order.invoice_number,
              :tax_cart => MoneyUtils.format_for_paypal(order.sales_tax),
              :shipping => MoneyUtils.format_for_paypal(order.shipping_cost),
              :paymentaction => payment_action,
              :shopping_url => APP_CONFIG[:paypal_shopping_url],
              :notify_url => ipn_url_with_secret}
    order.line_items.each_with_index do |item, index|
      values.merge!({
        "amount_#{index+1}" => MoneyUtils.format_for_paypal(item.unit_price),
        "item_name_#{index+1}" => item.product.name,
        "item_number_#{index+1}" => item.product_id,
        "quantity_#{index+1}" => item.quantity
      })
    end
    encrypt(values)
  end

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

  private

  def self.encrypt(values)

    signed = OpenSSL::PKCS7::sign(
      OpenSSL::X509::Certificate.new(APP_CERT_PEM),
      OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''),
      values.map { |k, v| "#{k}=#{v}" }.join("\n"),
      [],
      OpenSSL::PKCS7::BINARY)

    OpenSSL::PKCS7::encrypt(
      [OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)],
      signed.to_der,
      OpenSSL::Cipher::Cipher::new("DES3"),
      OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
  end

  #################### End PayPal Standard #########################

end

