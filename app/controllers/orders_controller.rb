class OrdersController < ApplicationController

  # You don't have to be logged in to create a new order.
  before_filter :require_user, :except => [:new, :create]

  def index
    user_store_url
    @user = current_user
    @orders = Order.paginate(:page => params[:page], :order => 'updated_at DESC',
      :conditions => ["user_id = ?" , @user.id], :per_page => 8)
  end

  def show
    user_store_url
    @user = current_user # will NOT be nil
    @order = Order.find(params[:id])
    
    # Any user could view any order, unless we prevent it.
    if @order.user_id != @user.id
      flash[:error] = "Invalid order ID"
      redirect_to user_last_url
    else
      @shipping = @order.shipping_address
      @billing = @order.billing_address
      @braintree_transactions = @order.braintree_transactions # best way to sort?
      @paypal_transactions = @order.paypal_transactions # best way to sort?
      @checking_out = false
    end
  end

  # This function displays the cart so the user can review the cart
  # contents and initiate payment.
  def new
    user_store_url
    # The current user will be nil if the customer is not logged in.
    @user = current_user
    @order = current_order
    @ip_address = request.remote_ip
    do_redirect = false
    if @order.line_items.count == 0
      flash[:notice] = "Please add items to your cart before you checkout."
      do_redirect = true
    elsif !(@order.shipping_address && @order.billing_address)
      flash[:notice] = "Please fill in billing and shipping addresses as you checkout."
      do_redirect = true
    end
    redirect_to current_cart_url if do_redirect
  end

  def edit
    user_store_url
    @user = current_user
    @order = Order.find(params[:id])

    # Any user could edit any order, unless we prevent it.
    if @order.user_id != @user.id
      flash[:error] = "Invalid order ID"
      redirect_to user_last_url
     end
  end

  def update
    user_store_url
    @user = current_user
    @order = Order.find(params[:id])

    if params[:commit] == "Cancel"
        flash[:notice] = 'Order was not modified.'
        redirect_to(@order)
    elsif params[:commit] == "Update Memo"
      if @order.user_id != @user.id
        flash[:error] = "Invalid order ID"
        redirect_to user_last_url
      elsif @order.update_attributes(params[:order])
        flash[:notice] = 'Order was successfully updated.'
        redirect_to(@order)
      else
        # Order update failed, error messages contained in @order.
        render :action => :edit
      end
    end
  end

  # Destroy is interpreted as cancelling the order.  The order is
  # not actually removed from the database. 
  def destroy
    @user = current_user
    @order = Order.find(params[:id])
    user_last_url
    if @order.user_id != @user.id
      flash[:error] = "Invalid order ID"
      redirect_to @user_last_url
    end
    if @order.cancel
      flash.now[:notice] = 'Order was cancelled.'
    else
      flash.now[:notice] = 'Order cannot be cancelled.'
    end
    render :action => :show
  end

end
