  require 'uri'
  require 'net/http'
  require 'cgi'

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
      res.body
    else
      res.error!
    end
  end

  ssl_post("https://www.wellsfargo.com/home", { 'asdf' => "d"}, "my-message")
