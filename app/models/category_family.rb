class CategoryFamily < ActiveRecord::Base
  belongs_to :category
  belongs_to :product_family
end
