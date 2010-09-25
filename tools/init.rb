#!/usr/bin/env ruby
#require File.expand_path('../../config/boot',  __FILE__)
#require File.expand_path('../../config/environment',  __FILE__)

Category.propagate_families
Category.propagate_products
Category.generate_attributes

puts "Initialization complete."

