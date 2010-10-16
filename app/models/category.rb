class Category < ActiveRecord::Base
  
  include OracleInterface::CategoryMethods
  
  # If you add ":dependent => destroy" to "has_many :category_products", 
  # RAILS generates an error when you try to destroy the category.  Maybe
  # this is because the join table has no "id" column.  Therefore,
  # we'll delete the associations ourselves in the callbacks.  Same goes
  # for "category_attributes" and "category_families".
  has_many :category_products
  has_many :products, :through => :category_products
  
  has_many :category_attributes
  has_many :product_attributes, :through => :category_attributes
  
  has_many :category_families
  has_many :product_families, :through => :category_families
  
  # Narrow selection to leaf categories.
  scope :leaves, 
   joins("LEFT OUTER JOIN categories child_cats " +
     "ON categories.id = child_cats.parent_id")
   .where("child_cats.id IS NULL")
   .order("categories.name ASC")

  scope :children,
    lambda {|parent_id| where(:parent_id => parent_id)}
  
  # Validations for create or update. The category name must be unique within
  # all children of the parent category, and the name field for the new 
  # category must not be blank.
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :parent_id
  
  after_destroy do |cat|
    CategoryProduct.delete_all(["category_id = ?", cat.id])
    CategoryFamily.delete_all(["category_id = ?", cat.id])
    CategoryAttribute.delete_all(["category_id = ?", cat.id])
    unless leaf?
      cat.reparent_children(cat.parent_id)
    end
    parent = Category.find(cat.parent_id)
    unless parent.leaf?
      parent.merge_families
      parent.merge_products
      parent.propagate_families_up
      parent.propagate_products_up
      parent.generate_attributes_up
    end
  end
  
  def add_subcat(name)
    was_leaf = leaf?
    child = Category.new(:parent_id => self.id, :name => name)
    if child.save
      if was_leaf
        # We just added the first child to a (former) leaf category.  Copy
        # all the CategoryFamily and CategoryProduct and CategoryAttribute
        # associations to the new leaf.  This will maintain all the inheritance
        # invariants. (Recall that the associations from the leaves
        # are propagated up the category tree.)  Copying down in this case 
        # works just as well.   
        logger.info "Copying associations from #{self.id} to #{child.id}."
        begin
          child.copy_associations(self.id)
        rescue Exception => e
          errors.add(:base, "Could not create child category: #{e}")
        end
      end
    else
      # Copy the errors to the parent category. The only error we're looking for
      # is the 'name is already taken'.
      if child.errors[:name]
        errors.add(:name, child.errors[:name])
      else
        errors.add(:base, "Could not create child category.")
      end
    end
  end
  
  # Move this category to be a child of the target category.
  def reparent(new_parent_id)
    new_parent = Category.find(new_parent_id)
    if new_parent.leaf?
      errors.add(:base, 
        "Can't reparent to a leaf category.")
    elsif get_descendents.include?(new_parent_id)
      errors.add(:base, 
        "Can't reparent a category to one of its own descendents.")
    else
      begin
        Category.transaction do 
          old_parent = Category.find(parent_id)

          # Move the node (and its subtree) to the new parent.
          update_attributes!(:parent_id => new_parent_id)

          # Fix up the product families, products, and attributes
          # where for old parent category.
          old_parent.merge_families
          old_parent.merge_products
          old_parent.propagate_families_up
          old_parent.propagate_products_up
          old_parent.generate_attributes_up

          # Fix up the product families, products, and attributes
          # where for new parent category.
          self.propagate_families_up
          self.propagate_products_up
          new_parent.generate_attributes_up
        end
      rescue Exception => e
        errors.add(:base, "Reparent of category failed: #{e}")
      end
    end
  end
  
  # Remove a product family from this category.  A product family may be
  # only removed from a leaf category, because the product families at
  # interior categories are completely determined by those at the leaves.
  # 
  # There may be products associated with the leaf category that belong to the
  # product family being removed.  Each such product must be removed from the
  # leaf category.  It must also be removed from all ancestor categories where
  # the product originated at this leaf.
  #
  def remove_family(fids, propagate = true)
    count = 0
    if leaf?
      [fids].flatten.each do |fid|
        fam = product_families.where(:id => fid).first
        if fam
          count += 1

          # Remove the association between the current category and the
          # given product family.
          product_families.delete(fam)

          # Remove the associations from the category_products table for
          # the current category and the given product_family.
          remove_products_in_family(fid)
        end
      end
    else
      errors.add(:base, "Can't remove a product family from a non-leaf category.")
    end
    if (count > 0) && propagate
      propagate_families_up
      generate_attributes_up
      propagate_products_up
    end
    count
  end
  
  #
  # Add a product family or array of product families to this category. A
  # product family may be only be added to a leaf category, because the product
  # families at interior categories are completely determined by those at the
  # leaves.
  #
  def add_family(fam, propagate = true)
    count = 0
    if leaf?
      [fam].flatten.each do |f|
        if product_families.where(["product_family_id = ?", f.id]).empty?
          product_families << f
          count += 1
        end
      end
    else
      errors.add(:base, "Can't add product family to non-leaf category.")
    end
    if (count > 0) && propagate
      propagate_families_up
      generate_attributes_up
    end
    count
  end
  
  # Remove a product from a leaf category, and possibly from all its ancestors.
  def remove_product(prod_id, propagate = true)
    if leaf?
      begin
        Category.transaction do
          CategoryProduct.delete_all(
            ["category_id = ? AND product_id = ?", self.id, prod_id])    
          propagate_products_up if propagate
        end
      rescue Exception => e
        errors.add(:base, "Removal of product failed: #{e}")
      end
    else
      errors.add(:base, "Can't delete product from interior category.")
    end
  end
  
  # Add a product to this leaf category.
  def add_product(prod_id, propagate = true)

    # Make sure that the product exists.
    begin
      prod = Product.find(prod_id)
    rescue
      errors.add(:base, "Can't find product using this product id.")
      return
    end

    # Can't add products to interior category.
    unless self.leaf?
      errors.add(:base, "Can't add product to interior category.")
      return
    end
    
    # Check for duplicate products in same category.
    unless CategoryProduct.where(:category_id => self.id,
      :product_id => prod_id).empty?
      errors.add(:base, "Can't add product to same category twice.")
      return
    end

    # Make sure that the category has the product's product family.
    if CategoryFamily.where(:category_id => self.id,
      :product_family_id => prod.product_family_id).empty?
      errors.add(:base, 
        "Category doesn't have product family for this product.")
      return
    end

    # All OK.  Add the product.
    Category.transaction do
      cat_prod = CategoryProduct.new(
        :category_id => self.id, :product_id => prod_id, :ref_count => 1) 
      category_products << cat_prod
      propagate_products_up if propagate
    end
  end

end
