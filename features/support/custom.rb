require File.expand_path(File.dirname(__FILE__) + '/../../spec/custom_matchers') # MBS
include CustomMatchers

# This solves: undefined method `render_template' for 
# #<Cucumber::Rails::World:0x87438564> (NoMethodError)
# require 'rspec/rails/matchers'
# include RSpec::Rails::Matchers::RenderTemplate

