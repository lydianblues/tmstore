namespace :store do
  desc "Create the root category."
  task :root => :environment do
    if root = Category.find_by_name("root")
      puts "Root category already exists."
    else
      root = Category.new(:name => 'root', :parent_id => nil, :depth => 0)
      if root.save
        puts "Root category created."
      else
        puts "Could not create root category."
      end
    end
  end

  desc "Create the admin user."
  task :admin => :environment do
     if User.find_by_login('admin')
       puts "Admin user already exists."
     else
        admin = User.new(:login => 'admin', :email => 'lydianblues@gmail.com',
          :password => 'rugrats', :password_confirmation => 'rugrats')
        admin.admin = true
        if admin.save
          puts "Admin user created."
        else
          puts "Could not create root admin."
        end
      end
  end

  desc "Create the root category and the admin user."
  task :init => [:admin, :root]

  desc "Propagate product families up from the leaves of the category tree."
  task :pfam => :environment do
    Category.propagate_families
  end

  desc "Propagate products up from the leaves of the category tree."
  task :pprod => :environment do
    Category.propagate_products
  end
 
  desc "Generate product attributes at all nodes of the category tree."
  task :gattr => :environment do
    Category.generate_attributes
  end

  desc "Generate attributes and propagate products and product families."
  task :sync => [:pfam, :pprod, :gattr]

  desc "Given an initialized, but empty store, create a basic store environment."
  task :testenv => :environment do
    if Category.all.size == 1
      require File.expand_path(File.dirname(__FILE__)) + '/../../spec/support/blueprints'
      require File.expand_path(File.dirname(__FILE__)) + '/../../spec/support/store_env'
      include StoreEnv
      build_store
    else
      puts "The store is not clean, please reset it first."
    end
  end

end
