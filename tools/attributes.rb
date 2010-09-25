require 'rubygems'
require 'active_record'

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../app/models/product_attribute'

myenv = ENV['RAILS_ENV']
myenv = 'development' unless myenv
dbconfig = YAML::load(File.open('../config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig[myenv])
ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = true

(1..1000).each do |i|
  ProductAttribute.create!(:name => "attr#{i}",
    :gname => "gattr#{i}", :atype => "string")
end