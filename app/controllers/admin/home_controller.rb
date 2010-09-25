class Admin::HomeController < ApplicationController
  
  before_filter :require_admin, :except => :bootstrap
  before_filter :admin_store_url
  layout "admin"
  
  def index
    @previous_url = nil
  end
  
  def bootstrap
    unless User.find_by_login('admin')
      admin = User.new(:login => 'admin', :email => 'admin@rugrats.com',
        :password => 'rugrats', :password_confirmation => 'rugrats', :admin => true)
      admin.save!
      current_user_session.destroy
    end
    unless Category.find_by_name('root')
     root = Category.new(:name => 'root', :parent_id => nil, :depth => 0)
     root.save!
    end
    redirect_to root_url
  end

end
