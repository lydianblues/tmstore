class Admin::OrdersController < ApplicationController

  layout "admin"
  before_filter :require_admin

  def index
    admin_store_url
    @orders = Order.paginate(:page => params[:page], :order => 'updated_at DESC',
      :per_page => 16)
  end

  def show
    @order = Order.find(params[:id])
    admin_store_url
  end

  def update
    @order = Order.find(params[:id])
    @user = current_user

    action = params[:_action]
    case action
    when "capture"
      @response = @order.capture(params, logger)
    when "void"
      @response = @order.void(params, logger)
    else
      raise ("Unknown order update action: #{action}")
    end
    if @response.success?
      flash.now[:notice] = "#{action.capitalize} successful."
    else
      flash.now[:error] = @response.message
    end
    admin_last_url
    render :template => "admin/orders/show"
  end

=begin
    @braintree_transactions = []
    @paypal_transactions = []
    unless @user.admin?
      flash.now[:notice] = "You must have admin privileges to update an order."
      render :template => "orders/show"
    else
      if params[:void]
        @order.void
        flash.now[:notice] = "Voiding the order (TBD)"
        render :template => "orders/show"
      end
      # params[:capture]
      # params[:refund]
      # params[:est_ship_date]
      # params[:shipped_date]
    end
  end
=end

end
