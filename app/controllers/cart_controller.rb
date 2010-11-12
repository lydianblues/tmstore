class CartController < ApplicationController

  #
  # Return URL (not the IPN URL) for PayPal. This is also the usual entry
  # point to show the contents of the shopping cart.
  #
  def show
    user_store_url
    if params[:transaction_subject] == "PayPal"
      process_paypal_redirect(params)
    end

    @order = current_order
    @user = current_user

    if @user && !@order.user
      @order.update_attribute(:user_id, @user.id)
    end
  end

  def update
    raise params.to_yaml
  end

  def destroy
    session[:order_id] = nil
    redirect_to current_cart_path
  end

  private

  def process_paypal_redirect(params)

    # We are in a redirect from PayPal.  This means that the customer
    # checked out via PayPal.  We couldn't freeze the cart earlier,
    # since we could not have known that the user would click the link
    # to pay with PayPal Standard.
    #
    # Important: we can't consider the order paid unless we do a postback
    # to find out for sure. Instead, we'll wait for the IPN.  No
    # PayPalTransaction is generated at this point.

    inv = Integer(params[:invoice])
    order = Order.find_by_invoice_number(inv)
    order.freeze_cart! unless order.approved?

    if params[:payment_status] == "Completed"
      session[:order_id] = nil
      flash.now[:notice] =
        "Your order for invoice #{params[:invoice]} is being processed.<br/>" +
        "The PayPal Transaction ID is #{params[:txn_id]}."
    else
      flash.now[:notice] =
        "Your order for invoice #{params[:invoice]} was not accepted.<br/>" +
        "Please try again or try a different payment method."
    end

    ##################### BEGIN TEMPORARY FOR TESTING ####################

    if PaypalTransaction.ipn_valid?(params)
      PaypalTransaction.record_transaction(params)
    end

    ##################### END TEMPORARY FOR TESTING ######################
  end

end
