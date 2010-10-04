module BootDB
  def create_root_category
    Category.make!(:root) unless Category.find_by_name("root")
  end

  def create_admin_user
    User.make!(:admin) unless User.find_by_login("admin")
  end

end
