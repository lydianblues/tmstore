class BraintreeTransaction < ActiveRecord::Base

  cattr_accessor :gateway

  belongs_to :order
  serialize :params

  def self.purchase(order, payment_source, options = {})
    options.merge!(:order_id => order.invoice_number)
    #order.start_processing!
    trans = order.braintree_transactions.build
    order.payment_method = "Braintree DP"

    # Save this price because the value from the cart changes to 0
    # if the transaction is approved.
    price_in_cents = order.total_without_shipping

    response = trans.process(order, 'purchase') do
      gateway.purchase(price_in_cents, payment_source, options)
    end

    if trans.success?
      order.update_attribute(:purchased_at, Time.now)
      message = "Your transaction with order id #{order.invoice_number} for " +
        "#{MoneyUtils.format(price_in_cents)} has been approved."
      order.approve!
    else
      order.decline!
      message = "Your transaction with order id #{order.invoice_number} has " +
        "been declined: #{trans.responsetext}"
    end
    message
  end

  def self.authorize(order, payment_source, options = {})
    options.merge!(:order_id => order.invoice_number)
    order.start_processing!
    trans = order.braintree_transactions.build
    order.payment_method = "Braintree DP"
    response = trans.process(order, 'authorization') do
      gw.authorize(order.price_in_cents, payment_source, options)
    end

    if trans.success?
      order.update_attribute(:purchased_at, Time.now)
      order.transaction_authorized!
    else
      order.transaction_declined!
    end

    [trans, response]
  end

  def self.capture(order, auth = nil, options = {})
    options.merge!(:order_id => order.invoice_number)
    auth = find_authorization(order) unless auth
    order.payment_method = "Braintree DP"
    trans = order.braintree_transactions.build
    response = trans.process(order, 'capture') do
      gw.capture(order.price_in_cents, auth, options)
    end

    if trans.success?
      order.transaction_approve!
    else
      order.transaction_decline!
    end
    [trans, response]
  end

  # Notification from Transparent Redirect

  def self.notify(order, params)
    message = nil
    success = false

    order.payment_method = "Braintree TR"
    #order.start_processing!
    if !(BraintreeTransaction.params_valid? params)
      message = "Parameter Validation Error"
    elsif order.invoice_number != params[:orderid].to_i
      message = "Incorrect Invoice Number, " +
        "expected #{order.invoice_number} " +
        "but got #{params[:orderid]}"
    elsif order.total_price.to_s != params[:amount]
       message =
        "Amount returned from processor gateway: #{params[:amount]} " +
        "does not match order total: #{order.total_price}"
    elsif params[:response] != "1"
      message =  message = "Your transaction with order id #{order.invoice_number} has " +
        "been declined: #{params[:responsetext]}"
    else
      message = "Your transaction with order id #{params[:orderid]} for " +
        "$#{MoneyUtils::number_to_currency(params[:amount])} has been approved."
      success = true
    end

    raise params[:amount]
    order.braintree_transactions << BraintreeTransaction.new(
      :message => message,
      :success => success,
      :params => params,
      :amount => MoneyUtils::decimal_string_to_cents(params[:amount]),
      :responsetext => params[:responsetext],
      :username => params[:username],
      :transactionid => params[:transactionid],
      :trans_type => params[:type],
      :action => params[:action],
      :authcode => params[:authcode].to_i,
      :response_code => params[:response_code].to_i,
      :response => params[:response].to_i)

    if success
      order.purchased_at = Time.now
      order.amount = order.price_in_cents
      order.transaction_approve!
    else
      order.transaction_decline!
    end

    order.save!

    # Send confirmation email

    message
  end

  def self.compute_hash(order)
    time_string = Time.now.utc.strftime '%Y%m%d%H%M%S'
    to_hash = "#{order.invoice_number}|#{order.estimated_total}|" +
      "#{time_string}|#{APP_CONFIG[:braintree_key]}"
    [time_string, Digest::MD5.hexdigest(to_hash)]
  end

  def self.params_valid?(params)
    to_hash = params[:orderid] + '|' + params[:amount] + '|' +
      params[:response] + '|' + params[:transactionid] + '|' +
      params[:avsresponse] + '|' + params[:cvvresponse] + '|' +
      params[:time] + '|' + APP_CONFIG[:braintree_key]
    Digest::MD5.hexdigest(to_hash) == params[:hash]
  end

  def process(order, action)

    amount = order.total_without_shipping
    logger.info "AMOUNT is #{amount}"

    begin
      response = yield
      resp = response.params
      logger.info "HERE IS THE RESPONSE {y resp}"
      attrs = {
        :amount => amount,
        :success => response.success?,
        :test => response.test,
        :params => response.params,
        :message => response.message,
        :authorization => response.authorization.to_i,
        :response => resp['response'].to_i,
        :responsetext => resp['responsetext'],
        :response_code => resp['response_code'].to_i,
        :authcode => resp['authcode'].to_i,
        :transactionid => resp['transactionid'],
        :action => action,
        :trans_type => resp['type']}

      if resp['orderid'].to_i != order.invoice_number
        attrs['success'] = false
        attrs['notes'] = "Inconsistent invoice number"
      end

    rescue ActiveMerchant::ActiveMerchantError => e
      logger.info "ACTIVE MERCHANT ERROR #{e.message}"
      success   = false
      reference = nil
      message   = e.message
      params    = {}
      test      = gateway.test?
    end
    update_attributes!(attrs)
    response
  end

  private

  def find_authorization(order)
    if authorization = order.braintree_transactions.find_by_action_and_success(
      'authorization', true, :order => 'id ASC')
      authorization.transactionid
    end
  end

  # This is unused.
  def complete_transaction(order, message, params)
    success = params[:response] == "1"
    order.braintree_transactions << BraintreeTransaction.new(
      :message => message,
      :success => success,
      :params => params,
      :amount => MoneyUtils::decimal_string_to_cents(params[:amount]),
      :responsetext => params[:responsetext],
      :username => params[:username],
      :transactionid => params[:transactionid],
      :action => params[:type],
      :authcode => params[:authcode].to_i,
      :response_code => params[:response_code].to_i,
      :response => params[:response].to_i)

    if success
      order.purchased_at = Time.now
      order.amount = order.price_in_cents
    end

    order.save!
  end

end
