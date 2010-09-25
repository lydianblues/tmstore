class Gateway::PaypalExpressController < ApplicationController

  #ssl_required :setup, :confirm, :purchase

  #
  # This is the Link target when customer clicks "Pay with PayPal" to start
  # a PayPal Express transaction.  This link is on both the cart/show
  # and order/new pages. We contact PayPal to set up some state for this
  # transaction.  A token is returned that we use to construct a URL for
  # the PayPal Express website.  Redirect the customer to this URL.
  #
  def setup
    ip = request.remote_ip
    order = current_order
    trans = order.paypal_transactions.build(:ip_address => ip)

    # Set up the transaction on PayPal. We can specify information
    # to customize the look and feel of the PayPal site and the
    # information it displays.
    options = {
      :ip => ip,
    }
    @response = trans.setup_purchase(options)

   if (@response.success?)
     # Redirect the customer to PayPal's website.
     redirect_to trans.redirect_url_for(@response.token)
   else
     flash[:notice] = "PayPal Express Setup Failed: #{@response.message}"
     redirect_to current_cart_url
   end
  end

  # Called from the user's browser (redirect from PayPal) after the user
  # confirms the purchase on PayPal's Review Order Page.  We contact
  # PayPal directly to get details about the customer (such as the address).
  def confirm
    trans, message = find_transaction_from_token(params[:token], "Confirmation")
    if trans
      @response = trans.details_for(current_user)
      if !@response.success?
        message = "PayPal Express Confirmation failed: #{@response.message}"
      end
    end
    if message
      flash[:notice] = message
      redirect_to current_cart_url
    else
      # render 'paypal_express/confirm'
      @order = trans.order
      @trans = trans
      @shipping = @order.shipping_address
    end
  end

  # Called when the user clicks "Complete PayPal Purchase" on our own
  # Review Order page.
  def purchase
    token = params[:token]
    payer_id = params[:PayerID]
    trans, message = find_transaction_from_token(token, "Purchase", payer_id)
    if trans
      options = {:token => token}
      @response = trans.express_payment(options)
      if !@response.success?
        message = "PayPal Express Payment failed: #{@response.message}"
      end
    end
    if message
      flash[:notice] = message
      redirect_to current_cart_url
    else
      flash[:notice] = "PayPal Express Payment succeeded. Your invoice number is " +
        "#{trans.order.invoice_number}."
      redirect_to root_path
    end
  end

  # Called from the user's browser (redirect from PayPal) when the user
  # clicks "Cancel" on PayPal's Review Order Page.  It may also called from
  # our own order review page.
  def cancel
    token = params[:token]
    trans, message = find_transaction_from_token(token, "Cancellation")
    if trans
      options = {
        :ip => request.remote_ip,
        :token => token,
        :payer_id => trans.payer_id}
      # Cancelling a transaction always succeeds unless the order has shipped.
      # This can't happen if we get here from PayPal's order review page.
      trans.cancel(options)
      flash[:notice] = "You cancelled your PayPal Express order."
    end
    if message
      flash[:notice] = message
    end
    redirect_to current_cart_url
  end

  private

  def find_transaction_from_token(token, opname, payer_id = nil)
    message = nil
    trans = PaypalTransaction.find_by_token(token)
    if trans.nil?
      message = "PayPal Express #{opname} Failed: No transaction " +
        "for token #{params[:token]}"
    elsif trans.order != current_order
      message = "PayPal Express #{opname} Failed: Order ID mismatch. " +
        "transaction order id = #{trans.order.id} and " +
        "current order id = #{current_order.id}"
      trans = nil
    elsif payer_id && payer_id != trans.payer_id
      message = "PayPal Express #{opname} Failed: Payer ID mismatch. " +
        "transaction payer id = #{trans.payer_id} and " +
        "parameter payer id = #{payer_id}"
      trans = nil
    end
    [trans, message]
  end

end
