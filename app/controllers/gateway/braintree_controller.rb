class Gateway::BraintreeController < ApplicationController
 
  protect_from_forgery :except => [:notify]
 
  def notify
    message = BraintreeTransaction.notify(current_order, params)
    flash[:notice] = message
    if current_user
      redirect_to account_url
    else
      redirect_to root_url
    end
  end
  
  #
  # Braintree Direct Post.
  #
  def create
    @order = current_order
    @order.freeze!

    if params[:commit] == APP_CONFIG[:braintree_direct_sale]

      credit_card = ActiveMerchant::Billing::CreditCard.new(
        :number => params[:ccnumber],
        :verification_value => params[:cvv],
        :month => params[:ccexp][0..1],
        :type => "Visa",
        :year => params[:ccexp][2..3])

      message = BraintreeTransaction.purchase(@order, credit_card)
      flash[:notice] = message

      if current_user
        redirect_to account_url
      else
        redirect_to root_url
      end

    end
  end
  
end
