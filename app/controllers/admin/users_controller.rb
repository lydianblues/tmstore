class Admin::UsersController < ApplicationController
  
  before_filter :require_admin
  before_filter :admin_store_url
  
  layout "admin"
  
  def index
  end

end
