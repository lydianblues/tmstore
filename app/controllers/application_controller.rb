require 'url_history'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  protect_from_forgery

  include SslRequirement

  URL_HISTORY_SIZE = 20

  # filter_parameter_logging :password, :password_confirmation

  # include SslRequirement

  include URLHistory

  # ActiveSupport::Rescuable::ClassMethods
  rescue_from AccessDenied, :with => :access_denied

  def current_order
    have_open_order = (session[:order_id] &&
      (@current_order = Order.find_by_id(session[:order_id])) && 
      !@current_order.purchased_at?)
    unless have_open_order
      @current_order = Order.create!
      if current_user
        @current_user.orders << @current_order
      end
      session[:order_id] = @current_order.id
    end
    @current_order
  end

  protected
  def access_denied
    redirect_to "/401.html"
  end

  private

  def require_user(msg = nil)
    unless user_signed_in?
      store_location
      flash[:notice] = msg ? msg : "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
    true
  end

  def require_no_user(msg = nil)
    if user_signed_in?
      store_location
      flash[:notice] = msg ? msg : "You must be logged out to access this page"
      redirect_to account_url
      return false
    end
  end

  def require_admin
    unless user_signed_in? && current_user.admin?
      flash[:notice] = "You do not have privileges to access the administrative area."
      redirect_to root_path
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def admin_last_url
    # The entry at the top of the stack has the current page.  Return
    # the previous page.
    @history = get_url_history(:admin_url_history, URL_HISTORY_SIZE)
    @previous_url = @history.peek2
  end

  def user_last_url
    # The entry at the top of the stack has the current page.  Return
    # the previous page.
    @history = get_url_history(:user_url_history, URL_HISTORY_SIZE)
    @previous_url = @history.peek2
  end

  def admin_store_url

    # We don't set @previous_url for XHR because we stay on same
    # page and so don't need to change the URL in the back link.
    unless request.xhr? || (request.request_method != 'GET')

      @history = get_url_history(:admin_url_history, URL_HISTORY_SIZE)
      request_url = request.fullpath
      parsed_request_url = URI.parse request_url

      if (parsed_request_url.path =~ /\/admin\/home(\/)?$/) ||
        (parsed_request_url.path =~ /\/admin(\/)?$/)
        @history.reset
      end

      query = parsed_request_url.query
      goback = query =~ /b=1$/

      if goback
        #
        # Top of stack has the page that contained the back button.
        # The next entry down should contain the url referenced in the
        # back button.  This should be the same url as the request_url
        # since the user must have just pushed a back button.
        # The third entry down contains the url for the 'previous_url'.
        #
        @history.pop
      else
        if query
          query << "&b=1"
        else
          query = "b=1"
        end
        parsed_request_url.query = query
        @history.push_if_new parsed_request_url.to_s
      end
      @previous_url = @history.peek2
      save_url_history(:admin_url_history, "/admin", @history)
      # @history.debug(logger)
    end
  end

  # Reset the URL history for the given role.  The 'role' may be
  # :admin or :user.
  def reset_url_history(role)  
    cookie_name = (role.to_s + "_url_history").to_sym
    history = get_url_history(cookie_name, URL_HISTORY_SIZE)
    history.reset
    save_url_history(cookie_name, "/", history)
  end

  def user_store_url

    # We don't set @previous_url for XHR because we stay on same
    # page and so don't need to change the URL in the back link.
    unless request.xhr? || (request.request_method != 'GET')

      @history = get_url_history(:user_url_history, URL_HISTORY_SIZE)

      request_url = request.fullpath
      parsed_request_url = URI.parse request_url
      query = parsed_request_url.query
      goback = query =~ /b=1$/

      if goback
        # In the case of a a redirect that uses the 'goback' feature,
        # the top of the stack has the page that invoked the redirect.
        #
        # In the case of pressing a 'back' button, the top of stack has
        # the page that contained the back button. The next entry down
        # should contain the url referenced in the back button.  This
        # should be the same url as the request_url, and the third entry
        # down contains the url for the 'previous_url'.
        #
        # In either case, pop the stack.
        #
        @history.pop
      else
        if query
          query << "&b=1"
        else
          query = "b=1"
        end
        parsed_request_url.query = query
        @history.push_if_new parsed_request_url.to_s
      end
      @previous_url = @history.peek2
      save_url_history(:user_url_history, "/", @history)
      @history.debug(logger)
    end
  end

  def current_billing_address
    address = current_order.billing_address
    if !address && current_user
      address = current_user.billing_address
    end
    address = current_order.build_billing_address unless address
    current_user.billing_address = address if current_user
    address
  end

  def current_shipping_address
     address = current_order.shipping_address
      if !address && current_user
        address = current_user.shipping_address
      end
      address = current_order.build_shipping_address unless address
      current_user.shipping_address = address if current_user
      address
  end

end

