# A Join table between Category and ProductAttributes.
class CategoryAttribute < ActiveRecord::Base
  belongs_to :category
  belongs_to :product_attribute
end