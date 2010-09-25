class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_login, :only => [:edit, :update, :show]

  def new
    raise "No 'new' action.  Use 'devise/registrations'#new."
  end

  def create
    raise "No 'create' action.  Use 'devise/registrations#create'."
  end

  def show
    user_store_url
    @user = current_user
    if params[:id] && params[:id] != "current" && @user.admin?
      @user = User.find(params[:id])
    end
  end

  # There is no view for this, until it becomes clear what editing
  # a user means.  The user can change his password through 
  # "devise/registrations#edit".
  def edit
    user_store_url
    @user = current_user
    if params[:id] && params[:id] != "current" && @user.admin?
      @user = User.find(params[:id])
    end
  end

  # Called from "devise/registrations#edit".
  def update
    if params[:commit] == "Accept"
      @user = current_user
      # Don't let the user change his login name.
      params[:user].delete(:login)
      @user.attributes = params[:user]
      if @user.save
          flash[:notice] = "Account updated!"
          redirect_back_or_default root_url
      else
        render :action => :edit
      end
    else
      flash[:notice] = "Your account was not modified."
      redirect_back_or_default root_url
    end
  end

  private
  def require_login
    require_user "You must be logged in to access your account."
  end

end
