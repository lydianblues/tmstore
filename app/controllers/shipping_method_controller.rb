class ShippingMethodController < ApplicationController

  include Shipping

  def new
    user_store_url
    @user = current_user
    @order = current_order
    @ups_rates = ups_rates(@order, current_shipping_address)
    @usps_rates = usps_rates(@order, current_shipping_address)
    @fedex_rates = fedex_rates(@order, current_shipping_address)
  end

  def create
    order = current_order
    carrier = params[:carrier]
    service_code = params[:service_code]
    save_rate_estimate(order, carrier, service_code)
    redirect_to new_order_path
  end

end

