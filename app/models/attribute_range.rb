=begin rdoc

  A ProductAttribute has a one-to-many association with AttributeRange objects.
  The set of attribute ranges for the attribute define the possible values
  the attribute can have.  (Think of the "domain" and "range" of a function).
  
  The value itself is stored in the attribute_values table. 

=end

class AttributeRange < ActiveRecord::Base
  belongs_to :product_attribute
  
  before_save :check_for_no_value

  def check_for_no_value
    if integer_val_low.blank? && integer_val_high.blank? && string_val.blank?
      raise "Can't save attribute range with no value."
    end
  end
  
end
