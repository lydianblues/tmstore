# A Join table between ProductFamily and ProductAttributes.
class CategoryProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :category

  before_save { |r| r.ref_count = 1 if r.new_record?}
end
