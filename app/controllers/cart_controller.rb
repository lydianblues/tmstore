class CartController < ApplicationController

  #
  # Return URL (not the IPN URL) for PayPal. This is also the usual entry
  # point to show the contents of the shopping cart.
  #
  def show
    user_store_url
    @order = current_order
    @user = current_user
  end

  def update
    raise params.to_yaml
  end

  def destroy
    session[:order_id] = nil
    redirect_to current_cart_path
  end


end
