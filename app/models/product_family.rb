class ProductFamily < ActiveRecord::Base
  
  validates_uniqueness_of :name
  validates_presence_of :name
  
  has_many :category_families
  has_many :categories, :through => :category_families
  
  has_many :family_attributes, :dependent => :destroy
  has_many :product_attributes, :through => :family_attributes
  
  has_many :products
  
  scope :default_sort, order("name ASC")
  
 def get_attributes(atype)          
    product_attributes.attr_type(atype) # using a named scope
  end
  
  #
  # Add a Product Attribute.  If you are adding (or removing) several
  # attributes, you should set 'propagate' to be false for all except
  # the last attribute.  Note that if the product family currently has
  # no categories, no propagation is done at this time.
  def add_attribute(attr, propagate = true)
    begin
      product_attributes << attr
    rescue Exception => e
      if String(e) =~ /ORA-00001/ # Oracle only
        errors.add_to_base "The attribute is already in the product family."
      else
        errors.add_to_base("Add attribute failed: #{e}")
      end
    else
      if propagate
        categories.each do |cat|
          cat.generate_attributes_up
        end
      end
    end
  end
  
  #
  # Remove a Product Attribute.  The attribute itself is not removed,
  # only its association with this Product Family. If you are removing
  # (or adding) several attributes, you should set 'propagate' to be
  # false for all except the last attribute.  Note that if the product
  # family currently has no categories, no propagation is done at this
  # time.
  #
  def remove_attribute(aid, propagate = true)
    fa = family_attributes.where(:product_attribute_id => aid).first
    if fa
      family_attributes.delete(fa)
      if propagate
        categories.each do |cat|
          cat.generate_attributes_up
        end
      end
    else
      errors.add_to_base "Product attribute is not in this product family."
    end
  end
  
  # Return all the leaf categories for this product family.  This returns
  # an array of Category model objects.
  def leaf_categories
    self.categories.leaves
  end
  
  # Return an array of hashes.  Each hash contains the id of a leaf
  # category (key is :catid), and the full path of the category
  # (key is :path).
  def leaf_category_paths
    paths = []
    # 'leaves' is a named scope on the category association collection.
    self.categories.leaves.each do |cat|
      paths << {:catid => cat.id, :path => cat.full_path}
    end
    paths
  end
  
  # Return the number of references the product family has in the given category.
  def refs_in_category(catid)
    cp = category_families.where(:category_id => catid).first
    cp.ref_count if cp
  end
  
end
