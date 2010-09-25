# A Join table between ProductFamily and ProductAttributes.
class FamilyAttribute < ActiveRecord::Base
  belongs_to :product_family
  belongs_to :product_attribute
end
