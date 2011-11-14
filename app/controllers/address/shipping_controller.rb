class Address::ShippingController < ApplicationController

#  ssl_required :create, :new, :edit, :show, :update

  def create
    address_options = params[:address]
    try_again = true

    if address_options
      shipping_address =
        current_order.create_or_update_shipping_address(
          current_user, address_options)
      if current_order.save && shipping_address.valid?
        current_user.save if current_user
        try_again = false
      end
    else
      try_again = false
    end

    if try_again
      user_store_url
      @user = current_user
      @address = current_shipping_address
      render :action => 'new'
    elsif params["_checkout"]
      redirect_to new_shipping_method_path(:_checkout => "1")
    else
      flash[:notice] = "Your shipping address has been created."
       # User goes back to previous page.
       redirect_to user_last_url
    end
  end

  def new
    user_store_url
    @order = current_order
    @address = current_shipping_address
    @user = current_user # might be nil
    @checkout = params[:_checkout]
  end

  def edit
    user_store_url
    @user = current_user
    @address = current_shipping_address
    @checkout = params[:_checkout]
  end

  def show
    user_store_url
     @address = current_shipping_address
  end

  def update
    @user = current_user
    again = false
    if params[:commit] == "Return"
      msg = "Your shipping address has not been changed."
    else
      address_options = params[:address]
      shipping_address =
        current_order.create_or_update_shipping_address(
          current_user, address_options)
      if current_order.save && shipping_address.valid?
        msg = "Your shipping address has been updated."
      else
        msg = "Your shipping address update failed."
        again = true
      end
    end
    flash[:notice] = msg
    if again
      user_last_url
      @address = shipping_address
      render :action => 'edit'
    else
      if params["_checkout"]
        redirect_to new_shipping_method_path(:_checkout => "1")
      else
        redirect_to user_last_url
      end
    end
  end

  private

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

  def get_ups_rates(order, to_address)
    packages = []
    # For now, assume that each product is shipped in a separate box, even when
    # there are many instances of the same product.
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
    origin = Location.new(  :country => 'US',
                            :state => 'CA',
                            :city => 'Oakland',
                            :zip => '94611')

    if to_address.country == 'Canada'
      destination = Location.new( :country => 'CA',
                            :province => to_address.province,
                            :city => to_address.city,
                            :postal_code => to_address.postal_code)
    elsif to_address.country == 'United States'
      destination = Location.new( :country => 'US',
                            :state => state_abbrevs(to_address.state),
                            :city => to_address.city,
                            :zip => to_address.postal_code)
    else
      raise "Can only ship to US and CA."
    end

    # Find out how much it'll be.
    ups = UPS.new(:login => APP_CONFIG[:ups_login], :password => APP_CONFIG[:ups_password],
                  :key => APP_CONFIG[:ups_access_key])
    begin
      response = ups.find_rates(origin, destination, packages)
    rescue Exception => e
      order.errors.add(:base, "Shipping calculation failed: #{e}")
      @ups_rates = []
    else
      @ups_rates = response.rates.sort_by(&:price).collect {|rate|
        {:service_name => rate.service_name,
         :service_code => rate.service_code,
         :price => rate.price}}
    end
  end

end
