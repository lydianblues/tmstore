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
  # Add a product attribute or an array of product attributes to a product
  # family.  Skip attributes already in the product family and return the
  # number of attributes added.
  #
  # There should be a validation on attribute creation that you can't create two
  # attributes with the same "gname".  Return the number of attributes added.
  #
  def add_attribute(attrs, propagate = true)
    count = 0
    [attrs].flatten.each do |attr|
      if product_attributes.where(["product_attribute_id = ?", attr.id]).empty?
        product_attributes << attr
        count += 1
        puts "Added attribute id=#{attr.id} with name #{attr.name} to product family id=#{self.id}"
      end
    end
    if (count > 0) && propagate
      categories.leaves.each do |cat|
        puts "Generating attributes up for category id = #{cat.id}"
        cat.generate_attributes_up
        puts "Category has #{cat.product_families.size} product families."
        puts "Category has #{cat.product_attributes.size} product attributes."
      end
    end
    count
  end
  
  #
  # Remove a product attribute or an array of product attributes from a product
  # family.  The attributes are not destroyed, only their association with the
  # product family. It is not an error if the attribute is not associated with
  # the product family.  Return the number of attributes removed.
  #
  def remove_attribute(aids, propagate = true)
    count = 0
    [aids].flatten.each do |aid|
      count += FamilyAttribute.where(:product_family_id => self.id,
        :product_attribute_id => aid).delete_all
    end
    if (count > 0) && propagate
      categories.leaves.each do |cat|
        cat.generate_attributes_up
      end
    end
    count
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

  #
  # There is at most one entry in the category_families table for the current
  # product family and the given category.  Find these record and return its
  # ref_count.  If it doesn't exist, return nil.  This function is 
  # useless since the ref_count currently isn't maintained. XXX
  #
  def refs_in_category(catid)
    cf = category_families.where(:category_id => catid).first
    cf ? cf.ref_count : nil
  end
  
end
