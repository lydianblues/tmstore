# A Join table between ProductFamily and ProductAttributes.
class CategoryProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :category
 
end
