module Shipping

  include ActiveMerchant::Shipping

  def ups_rates(order, to_address)
    packages = []

    if order.line_items.size == 0
      # No packages...
      return [{:service_name =>"No packages in your order", :service_code => "0", :price => 0}]
    end

    # For now, assume that each product is shipped in a separate box, even when
    # there are many instances of the same product.  Otherwise, we have to
    # maintain the weight and dimensions of a product *before* it is placed in
    # a shipping box, then invoke a NP-complete packing algorithm to figure out
    # what shipping box(es) should be chosen, and which products should be packed
    # in each shipping box.
    order.line_items.each do |li|
      product = li.product
      1.upto(li.quantity) do

        if product.shipping_cylinder?
          packages << Package.new(
                                  product.shipping_weight, # ounces or grams
                                  [product.shipping_length, product.shipping_width],
                                  :cylinder => true,
                                  :units => product.shipping_units.downcase.to_sym)
        else
          packages << Package.new(
                                  product.shipping_weight, # ounces or grams
                                  [product.shipping_length, product.shipping_width,
                                   product.shipping_height],
                                  :units => product.shipping_units.downcase.to_sym)
        end
      end
    end

    # Put the shipper parameters in APP_CONFIG.
    origin = Location.new(:country => 'US',
                          :state => 'CA',
                          :city => 'Oakland',
                          :zip => '94611')
    if to_address.country == 'Canada' || to_address.country == 'CA'
      destination = Location.new(:country => 'CA',
                                 :province => to_address.province,
                                 :city => to_address.city,
                                 :postal_code => to_address.postal_code)
    elsif to_address.country == 'United States' || to_address.country == 'US'
      destination = Location.new( :country => 'US',
                            :state => state_abbrevs(to_address.state),
                            :city => to_address.city,
                            :zip => to_address.postal_code)
    else
      raise "Can only ship to US and CA. to_address = #{to_address.to_yaml}"
    end

    # Find out how much it'll be.
    ups = UPS.new(:login => APP_CONFIG[:ups_login], :password => APP_CONFIG[:ups_password],
                  :key => APP_CONFIG[:ups_access_key])
    begin
      response = ups.find_rates(origin, destination, packages)
    rescue Exception => e
      order.errors.add(:base, "Shipping rate calculation failed: #{e}")
      ups_rates = []
    else
      ups_rates = response.rates.sort_by(&:price).collect {|rate|
        {:service_name => rate.service_name,
         :service_code => rate.service_code,
         :price => rate.price}}
    end
    ups_rates
  end

  def usps_rates(order, to_address)
    nil # TODO
  end

  def fedex_rates(order, to_address)
    nil # TODO
  end

  def save_rate_estimate(order, carrier, service_code)
    # Contact the carrier a second time to get the rates.  We can't trust a
    # rate quote that was passed to us from the user.  Alternatively, when we
    # first contact the carrier, we could save the rate quotes in the database.
    # This is simpler (but lower performance), but it will do for now.
    case carrier
    when "ups"
      service_code = "03" unless service_code # default for UPS is "Ground"
      service_name = ups_service_name(service_code)
      rates = ups_rates(order, order.shipping_address)
      s = rates.select {|r| r[:service_code] == service_code}[0]
      price = nil
      price = s[:price] if s
    when "usps"
      # TODO
      service_name = nil
      price = nil
    when "fedex"
      # TODO
      service_name = nil
      price = nil
   end
   order.update_attributes(:carrier => carrier,
                           :service_name => service_name,
                           :service_code => service_code,
                           :shipping_cost => price)
  end

  private

  # Only for shipments originating in the United States.
  def ups_service_name(code)
    service_hash = {
      "01" => "UPS Next Day Air",
      "02" => "UPS Second Day Air",
      "03" => "UPS Ground",
      "07" => "UPS Worldwide Express",
      "08" => "UPS Worldwide Expedited",
      "11" => "UPS Standard",
      "12" => "UPS Three-Day Select",
      "13" => "UPS Next Day Air Saver",
      "14" => "UPS Next Day Air Early A.M.",
      "54" => "UPS Worldwide Express Plus",
      "59" => "UPS Second Day Air A.M.",
      "65" => "UPS Saver",
    }
    service_hash[code]
  end

  def state_abbrevs(full_name)
    state_hash = {
      "Alabama" =>  "AL",
      "Alaska" => "AK",
      "Arizona" => "AZ",
      "Arkansas" => "AR",
      "California" => "CA",
      "Colorado" => "CO",
      "Connecticut" => "CT",
      "Delaware" => "DE",
      "District Of Columbia" => "DC",
      "Florida" => "FL",
      "Georgia" => "GA",
      "Hawaii" => "HI",
      "Idaho" => "ID",
      "Illinois" => "IL",
      "Indiana" => "IN",
      "Iowa" => "IA",
      "Kansas" => "KS",
      "Kentucky" => "KY",
      "Louisiana" => "LA",
      "Maine" => "ME",
      "Maryland" => "MD",
      "Massachusetts" => "MA",
      "Michigan" => "MI",
      "Minnesota" => "MN",
      "Mississippi" => "MS",
      "Missouri" => "MO",
      "Montana" => "MT",
      "Nebraska" => "NE",
      "Nevada" => "NV",
      "New Hampshire" => "NH",
      "New Jersey" => "NJ",
      "New Mexico" => "NM",
      "New York" => "NY",
      "North Carolina" => "NC",
      "North Dakota" => "ND",
      "Ohio" => "OH",
      "Oklahoma" => "OK",
      "Oregon" => "OR",
      "Pennsylvania" => "PA",
      "Rhode Island" => "RI",
      "South Carolina" => "SC",
      "South Dakota" => "SD",
      "Tennessee" => "TN",
      "Texas" => "TX",
      "Utah" => "UT",
      "Vermont" => "VT",
      "Virginia" => "VA",
      "Washington" => "WA",
      "West Virginia" => "WV",
      "Wisconsin" => "WI",
      "Wyoming" => "WY"
    }
    state_hash[full_name]
  end

end
