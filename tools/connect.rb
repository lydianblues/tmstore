# -*- coding: utf-8 -*-
require 'net/https'
require 'uri'

class MyConnection

  Message = "mc_gross=213.84&invoice=906566721571&protection_eligibility=Eligible&address_status=confirmed&item_number1=10001&payer_id=MPR7X7K8DAJQQ&tax=15.84&address_street=1 Main St&payment_date=11:06:13 Apr 24, 2010 PDT&payment_status=Completed&charset=windows-1252&address_zip=95131&mc_shipping=0.00&mc_handling=0.00&first_name=Test&mc_fee=6.50&address_country_code=US&address_name=Test User&notify_version=2.9&custom=PayPalStandard&payer_status=verified&business=store_1233166355_biz@thirdmode.com&address_country=United States&num_cart_items=1&mc_handling1=0.00&address_city=San Jose&verify_sign=AV.sETNyBIaNLdwJwYjO8.idB474AEkneGz5oBiHwDIc.ZzGWE1ygQ1O&payer_email=buyer_1233697850_per@thirdmode.com&mc_shipping1=0.00&txn_id=7BU07491E81525621&payment_type=instant&last_name=User&address_state=CA&item_name1=Another Disk&receiver_email=store_1233166355_biz@thirdmode.com&payment_fee=6.50&quantity1=9&receiver_id=VTZYXLBLW6VMC&txn_type=cart&mc_gross_1=198.00&mc_currency=USD&residence_country=US&test_ipn=1&transaction_subject=PayPalStandard&payment_gross=213.8"

  # A random example from http://www.ruby-forum.com/topic/133283
  def send_email(msg, type, activity)
    req = "type=#{type}&activity=#{activity}&input="
    req = req + URI.escape(msg)
    begin
      Net::HTTP.start('www.uptilt.com') do |query|
        response = query.post("/API/mailing_list.html", req)
        @response = response.body
      end
    rescue
      @error = true
      @error_msg = "Unable to connect to Email Labs."
      return false
    end
  end

  def self.acknowledge_ipn

    url = URI.parse('https://www.sandbox.paypal.com/cgi-bin/webscr')

    # Create and Initalize the Post object.
    req = Net::HTTP::Post.new(url.path)
    req.body = 'cmd=_notify-validate&' + Message
    req.content_type = 'application/x-www-form-urlencoded'

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
      puts "SUCCESS"
    else
      res.error!
    end
  end




 #     #3: Detailed control
  #     url = URI.parse('http://www.example.com/todo.cgi')
  #     req = Net::HTTP::Post.new(url.path)
  #     req.basic_auth 'jack', 'pass'
  #     req.set_form_data({'from' => '2005-01-01', 'to' => '2005-03-31'}, ';')
  #     res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
  #     case res
  #     when Net::HTTPSuccess, Net::HTTPRedirection
  #       # OK
  #     else
  #       res.error!
  #     end




  # ca_file has to point to a file containing certificates from certificate authorities.
  # Usually, you can find such a file on nearly every system, because it comes with web  # browsers, curl, and so on.

  # Then, you have to set enable_post_connection_check to true! Otherwise, a message gets
  # logged to the console, but no exception is raised.

  def self.ssl_connect(url)

    msg = "cmd=_notify-validate&" + Message

    https = Net::HTTP.new(url, Net::HTTP.https_default_port)
    https.use_ssl = true
    https.ssl_timeout = 2
    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    https.ca_file = File.expand_path('../security/ca-bundle.crt', __FILE__)
    https.verify_depth = 2
    # https.enable_post_connection_check = true
    r = https.start do |http|
      request = Net::HTTP::Get.new('/')
      # request = Net::HTTP::Post.new("/cgi-bin/webscr", msg)
      response = https.request(request)
    end
    puts r
  end
end

# MyConnection.ssl_connect("www.sandbox.paypal.com")
MyConnection.acknowledge_ipn

