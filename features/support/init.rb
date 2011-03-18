def create_root_category!
  unless Category.find_by_name("root")
    root = Category.new(:name => 'root', :parent_id => nil, :depth => 0)
    root.save!
  end
end

def create_admin!
  unless User.find_by_login('admin')
    admin = User.new(:login => 'admin', :email => 'lydianblues@gmail.com',
      :password => 'rugrats', :password_confirmation => 'rugrats')
    admin.admin = true
    admin.save!
  end
end
