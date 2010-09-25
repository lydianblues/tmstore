module PaypalAPI

  API_Username = "store_1233166355_biz_api1.thirdmode.com"
  API_Password =  "1233166361"
  API_Signature = "ALZ2S3NXdLgg9g1ENcUy0awyGQAfAQk88a4VgQF0kt2yFDbnZ9SZjIAw"
  API_Mode = "sandbox"
  PayPal_Secret = "s5a8l4a9"

  SANDBOX_URL = "https://api-3t.sandbox.paypal.com/nvp"
  LIVE_URL = "https://api-3t.paypal.com/nvp"
  
  # These must be converted to use HTTPS, after I get a certificate for deimos.
  # Deimos will be the name of the callback server.
  IPN_URL = "https://deimos.thirdmode.com/notify?secret=" + PayPal_Secret
  CALLBACK_URL = "https://deimos.thirdmode.com/update"

  # PayPal recommends that the value be the final review page on which the
  # customer confirms the order and payment or billing agreement.
  RETURN_URL = "https://store/paypal/express_confirm" # paypal_express_confirm_url

  # PayPal recommends that the value be the original page on which the
  # customer chose to pay with PayPal or establish a billing agreement.
  CANCEL_URL = "https://store/paypal/express_cancel" # paypal_express_cancel_url

  REQUIRED_SECURITY_PARAMETERS = { 
    :USER => API_Username,
    :PWD => API_Password,
    :SIGNATURE => API_Signature,
    :VERSION => "62.0",
  }
  PAYPAL_API_URL = SANDBOX_URL

  class Response
    attr_accessor :details

    def initialize(response_hash)
      @details = response_hash
    end

    def success?
      @details[:ACK] == "Success"
    end

    def token
      @details[:TOKEN]
    end

    def message
      "A meaningful message."
    end

  end

  #============================ Address Verify ================================#
  #                                                                            #
  # See Chapter 2 of the "Name-Value Pair API Developer Guide"                 #
  #                                                                            #
  # Apparently, you must contact PayPal must enable this on your merchant      #
  # account.                                                                   #
  #                                                                            #
  #============================================================================#

  Address_Verify = {
    :METHOD => "AddressVerify",
    :EMAIL => "buyer_1233697850_per@thirdmode.com",
    :STREET => "1 Main St",
    :ZIP => "95131"
  }

  #========================= Authorization & Capture ==========================#
  #                                                                            #
  # See Chapter 3 of the "Name-Value Pair API Developer Guide", and Chapter 8  #
  # of the "Website Payments Standard Integration Guide".  The latter document #
  # contains some scenarios.                                                   #
  #============================================================================#

  Do_Capture = {
    :METHOD => "DoCapture",
    :AUTHORIZATIONID => nil,
    :COMPLETETYPE => "Complete", # or "NotComplete"
    :AMT => nil,
    :CURRENCYCODE => "USD",
    :COMPLETETYPE => nil,
    :INVNUM => nil,
    :NOTE => nil,
    :SOFTDESCRIPTOR => nil
  }
  def do_capture(options)
    opts = REQUIRED_SECURITY_PARAMETERS.merge(Do_Capture)
    opts.merge!(options)
    opts.delete_if { |k,v| v.blank? }
    response_hash = ssl_post(PAYPAL_API_URL, opts)
    Response.new(response_hash)
  end

  Do_Authorization = {
    :METHOD => "DoAuthorization",
    :TRANSACTIONID => nil,
    :AMT => nil,
    :CURRENCYCODE => "USD"
  }
  def do_authorization(options)
    opts = REQUIRED_SECURITY_PARAMETERS.merge(Do_Authorization)
    opts.merge!(options)
    opts.delete_if { |k,v| v.blank? }
    response_hash = ssl_post(PAYPAL_API_URL, opts)
    Response.new(response_hash)
  end

  Do_Reauthorization = {
    :METHOD => "DoReauthorization",
    :AUTHORIZATIONID => nil,
    :AMT => nil,
    :CURRENCY_CODE => "USD"
  }
 def do_reauthorization(options)
    opts = REQUIRED_SECURITY_PARAMETERS.merge(Do_Reauthorization)
    opts.merge!(options)
    opts.delete_if { |k,v| v.blank? }
    response_hash = ssl_post(PAYPAL_API_URL, opts)
    Response.new(response_hash)
  end

  Do_Void = {
    :METHOD => "DoVoid",
    :AUTHORIZATIONID => nil,
    :NOTE => nil
  }
 def do_void(options)
    opts = REQUIRED_SECURITY_PARAMETERS.merge(Do_Void)
    opts.merge!(options)
    opts.delete_if { |k,v| v.blank? }
    response_hash = ssl_post(PAYPAL_API_URL, opts)
    Response.new(response_hash)
  end

  #============================== Direct Payment ==============================#
  #                                                                            #
  # See Chapter 4 of the "Name-Value Pair API Developer Guide"                 #
  #                                                                            #
  # Direct Payment has a single API operation.                                 #
  #                                                                            #
  #============================================================================#

  Do_Direct_Payment = {
    :METHOD => "DoDirectPayment",
    :NOTIFYURL => IPN_URL,
    :PAYMENTACTION => "Sale", # "Authorization" or "Sale"
    :IPADDRESS => nil,
    :RETURNFMFFILTERS => "0",
    :CREDITCARDTYPE => nil,
    :ACCT => nil, # Credit card number
    :EXPDATE => nil, # Format MMYYYY
    :CVV2 => nil,
    :AMT => nil, # Format is "11.23", for example
    :FIRSTNAME => nil,
    :LASTNAME => nil
  }

  def do_direct_payment(options)
    opts = REQUIRED_SECURITY_PARAMETERS.merge(Do_Direct_Payment)
    opts.merge!(
      :AMT => options[:amount],
      :PAYMENTACTION => options[:payment_action],
      :IPADDRESS => options[:ip_address],
      :CREDITCARDTYPE => options[:card_type],
      :ACCT => options[:card_number],
      :EXPDATE => options[:exp_date],
      :CVV2 => options[:cvv2],
      :FIRSTNAME => options[:first_name],
      :LASTNAME => options[:last_name])
    opts.delete_if { |k,v| v.blank? }
    response_hash = ssl_post(PAYPAL_API_URL, opts)
    Response.new(response_hash)
  end

  #========================= PayPal Express Checkout ==========================#
  #                                                                            #
  # See p. 84 of the "Website Payments Pro Integration Guide" and              #
  # Chapter 4 of the "Name-Value Pair API Developer Guide".                    #
  #                                                                            #
  # Typical API sequence:                                                      #
  # 1. Call SetExpressCheckout, get Token.                                     #
  # 2. Receive Callback (from Paypal), send Callback Response (to Paypal)      #
  # 3. ... wait for the user to be redirected to our RETURN URL...             #
  # 4. Call GetExpressCheckoutDetails (with Token), get Response.              #
  # 5. Call DoExpressCheckoutPayment (with Token), get Response.               #
  # 6. Receive IPN.                                                            #
  #                                                                            #
  #============================================================================#

  Set_Express_Checkout = {
   :METHOD =>  "SetExpressCheckout",
   :NOTIFYURL => IPN_URL,
    # :CALLBACK => CALLBACK_URL,
    # :L_SHIPPINGOPTIONISDEFAULTn => nil, # Required if using callback
    # :L_SHIPPINGOPTIONNAMEn => nil, # Required if using callback
    # :L_SHIPPINGOPTIONAMOUNTn => nil, # Required if using callback
   :AMT => nil,
   :CURRENCYCODE => "USD",
   :RETURNURL => nil,
   :CANCELURL => nil,
   :CALLBACK => nil
  }

  def set_express_checkout(options)
    opts = REQUIRED_SECURITY_PARAMETERS.merge(Set_Express_Checkout)
    opts.merge!(
      :AMT => options[:amount],
      :RETURNURL => options[:return_url],
      :CANCELURL => options[:cancel_url],
      :CALLBACK => options[:callback_url])
    opts.delete_if { |k,v| v.blank? }
    response_hash = ssl_post(PAYPAL_API_URL, opts)
    Response.new(response_hash)
  end

  # From Paypal to Merchant.
  Callback = {
    :METHOD => "Callback",
    :TOKEN => nil,
    :CURRENCYCODE => nil,
    :LOCALECODE => nil,
    :L_NAME0 => nil,
    :L_NUMBER0 => nil,
    :L_DESC0 => nil,
    :L_AMT0 => nil,
    :L_QTY0 => nil,

    :L_ITEMWEIGHTVALUE0 => nil,
    :L_ITEMWEIGHTUNIT0 => nil,
    :L_ITEMHEIGHTVALUE0 => nil,
    :L_ITEMHEIGHTUNIT0 => nil,
    :L_ITEMWIDTHVALUE0 => nil,
    :L_ITEMWIDTHUNIT0 => nil,
    :L_ITEMLENGTHVALUE0 => nil,
    :L_ITEMLENGTHUNIT0 => nil,

    :SHIPTOSTREET => nil,
    :SHIPTOSTREET2 => nil,
    :SHIPTOCITY => nil,
    :SHIPTOSTATE => nil,
    :SHIPTOZIP => nil,
    :SHIPTOCOUNTRY => nil
  }

  # From Merchant to Paypal.
  Callback_Response = {
    :METHOD => "CallbackResponse",
    :L_SHIPPINGOPTIONNAME0 => "Air",
    :L_SHIPPINGOPTIONLABEL0 => "Air Label",
    :L_SHIPPINGOPTIONISDEFAULT0 => "false",
    :L_SHIPPINGOPTIONAMOUNT0 => "23.55",

    :L_SHIPPINGOPTIONNAME1 => "Ground",
    :L_SHIPPINGOPTIONLABEL1 => "Ground Label",
    :L_SHIPPINGOPTIONISDEFAULT1 => "true",
    :L_SHIPPINGOPTIONAMOUNT1 => "11.55"
  }

  Get_Express_Checkout_Details = {
    :METHOD => "GetExpressCheckoutDetails",
    :NOTIFY_URL => IPN_URL,
    :TOKEN => nil
  }

  def get_express_checkout_details(token)
    opts = REQUIRED_SECURITY_PARAMETERS.merge(Get_Express_Checkout_Details)
    opts[:TOKEN] = token
    opts.delete_if { |k,v| v.blank? }
    response_hash = ssl_post(PAYPAL_API_URL, opts)
    Response.new(response_hash)
  end

  Do_Express_CheckoutPayment = {
    :METHOD => "DoExpressCheckoutPayment",
    :NOTIFYURL => IPN_URL,
    :TOKEN => nil,
    :PAYMENTACTION => "Sale", # "Sale", or "Authorization", or "Order"
    :PAYERID => nil, # from GetExpressCheckoutDetails Response
    :AMT => nil,
    :CURRENCYCODE => "USD"
  }

  def do_express_checkout_payment(options)
    opts = REQUIRED_SECURITY_PARAMETERS.merge(Get_Express_Checkout_Details)
    opts.merge!(
      :AMT => options[:amount],
      :TOKEN => options[:token],
      :PAYMENTACTION => options[:payment_action],
      :PAYERID => options[:payer_id])
    opts.delete_if { |k,v| v.blank? }
    response_hash = ssl_post(PAYPAL_API_URL, opts)
    Response.new(response_hash)
  end

  #=============================== RefundTransaction ==========================#
  #                                                                            #
  # See Chapter 13 of the "Name-Value Pair API Developer Guide", and Chapter   #
  # 13 of the "Website Payments Pro Integration Guide".                        #
  #                                                                            #
  #============================================================================#

  Refund_Transaction = {
    :METHOD => "RefundTransaction",
    :TRANSACTIONID => nil,
    :REFUNDTYPE => "Partial", # or "Full"
    :AMT => nil,
    :CURRENCYCODE => "USD",
    :NOTE => nil 
  }
  def refund_transaction(options)
    opts = REQUIRED_SECURITY_PARAMETERS.merge(Refund_Transaction)
    opts.merge!(options)
    opts.delete_if { |k,v| v.blank? }
    response_hash = ssl_post(PAYPAL_API_URL, opts)
    Response.new(response_hash)
  end

  private

  # The 'extra' parameter is a NVP string, already URL encoded.
  def ssl_post(url_string, name_value_hash, extra = nil)

    url = URI.parse(url_string)

    # Create and Initalize the Post object.
    req = Net::HTTP::Post.new(url.path)

    # Also sets contet-type to 'application/x-www-form-urlencoded'
    req.set_form_data(name_value_hash)

    if extra
      req.body += "&" + extra
    end

    # Create and initialize the HTTP object for the https protocol.
    https = Net::HTTP.new(url.host, Net::HTTP.https_default_port)
    https.use_ssl = true
    https.ssl_timeout = 2

    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    https.ca_file = File.expand_path('../security/ca-bundle.crt', __FILE__)
    https.verify_depth = 2

    res = https.start {|http| http.request(req)}
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      response_to_hash(res.body)
    else
      res.error! # Creates exception object and raises exception.
    end
  end

  def response_to_hash(resp)
    myhash = {}
    resp.split('&').each do |s|
      key, val = s.split('=')
      myhash[CGI::unescape(key).to_sym] = CGI.unescape(val)
    end
    myhash
  end

end

