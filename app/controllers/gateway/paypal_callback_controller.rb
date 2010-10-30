class Gateway::PaypalCallbackController < ApplicationController

  protect_from_forgery :except => [:notify, :update]
 
  ssl_required :update, :notify

  # PayPal Instant Update API
  def update
    raise "PayPal Instant Update not yet implemented."
  end

  # Instant Payment Notification (IPN).
  def notify
    PAYPAL_IPN_HANDLER.acknowledge_ipn(request) do |opts|
      trans = PaypalTransaction.find_by_txn_id(opts[:txn_id])
      if trans
        trans.handle_ipn(opts)
      else
        logger.warn "Couldn't find PayPal transaction for id #{opts[:custom]}"
      end
    end
    render :nothing => true
  end

end
