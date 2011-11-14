class Address::BillingController < ApplicationController

#  ssl_required :create, :new, :edit, :show, :update, :destroy

  def create
    address_options = params[:address]
    shipping_address = nil

    billing_address =
      current_order.create_or_update_billing_address(
        current_user, address_options)

    if billing_address.valid? && params[:same_as_billing]
      shipping_address = 
        current_order.create_or_update_shipping_address(
          current_user, address_options)
    end

    # If the Billing Address was valid, but the Shipping address was
    # not, show the shipping address form even if the user said that
    # the Billing was the same as Shipping.  The user won't see the
    # current Shipping validation errors. (That information is lost in
    # the redirect.)

    if current_order.save && billing_address.valid?
      current_user.save if current_user
      if in_checkout
        if shipping_address && shipping_address.valid?
          flash[:notice] = 
           "Your billing was created, and shipping address was created " +
           "or updated to match."
          # User will now choose shipping method.
          redirect_to new_shipping_method_path
        else
          # User must enter a shipping address.
          flash[:notice] = "Your billing address have been saved."
          redirect_to new_address_shipping_path(:_checkout => "1")  
        end
      else
        flash[:notice] = "Your billing address has been saved."
        # User goes back to previous page.
        redirect_to user_last_url
      end
    else
      @user = current_user
      @address = billing_address # was current_billing_address
      render :action => 'new'
    end
  end

  def new
    user_store_url
    @user = current_user
    @address = current_billing_address
    @checkout = in_checkout
  end

  def edit
    user_store_url
    @user = current_user
    @address = current_billing_address
    @checkout = in_checkout
  end

  def show
    user_store_url
    @user = current_user
    @address = current_billing_address
  end

  def update
    again = false
    @user = current_user
    if params[:commit] == "Cancel"
      msg = "Your billing address has not been changed."
    else
      address_options = params[:address]
      billing_address =
        current_order.create_or_update_billing_address(
          current_user, address_options)
      if current_order.save && billing_address.valid?
        msg = "Your billing address has been updated."
      else
        msg = "Your billing address update failed."
        again = true
      end
    end
    flash[:notice] = msg

    if again
      @address = billing_address
      render :action => 'edit'
    else
      if in_checkout
        redirect_to new_address_shipping_path(:_checkout => "1")
      else
        redirect_to user_last_url
      end
    end
  end

  def destroy
  end

end
