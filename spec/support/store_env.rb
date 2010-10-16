#
# Create a complete store "Environment".  That is, build a category tree,
# create product families and add them them to leaves of the category tree,
# and add family attributes to the product familes. Verify that everything
# propagates properly up from the leaves.
#
module StoreEnv

  def build_store
    build_categories
    build_product_families
    build_family_attributes
  end

  def build_categories
    @root = Category.find(Category.root_id)
    @cat1 = Category.make!(:name => "cat1", :parent_id => @root.id )
    @cat2 = Category.make!(:name => "cat2", :parent_id => @root.id )
    @cat11 = Category.make!(:name => "cat11", :parent_id => @cat1.id )
    @cat12 = Category.make!(:name => "cat12", :parent_id => @cat1.id )
    @cat13 = Category.make!(:name => "cat13", :parent_id => @cat1.id )
    @cat121 = Category.make!(:name => "cat121", :parent_id => @cat12.id )
    @cat122 = Category.make!(:name => "cat122", :parent_id => @cat12.id )
    @cat123 = Category.make!(:name => "cat123", :parent_id => @cat12.id )
    @cat131 = Category.make!(:name => "cat131", :parent_id => @cat13.id )
    @cat1221 = Category.make!(:name => "cat1221", :parent_id => @cat122.id )
    @cat1222 = Category.make!(:name => "cat1222", :parent_id => @cat122.id )
  end

  def refresh_category_refs
    Category.all.each do |c|
      instance_variable_set("@" + c.name, c)
    end
  end

  def build_product_families
    leaf_category_families.keys.each do |cfk|
      ivar = "@" + String(cfk)
      cat = instance_variable_get(ivar)
      if cat
        leaf_category_families[cfk].each do |j|
          fam = find_or_create_product_family(j)
          cat.add_family(fam)
        end
      end
    end
  end

  def build_family_attributes
    family_attributes.each_with_index do |row, i|
      name = "@fam#{i + 1}"
      fam = instance_variable_get(name)
      row.each_with_index.each do |flag, j|
        next unless flag == 1
        attr = find_or_create_attribute(j + 1)
        fam.add_attribute(attr, false)
      end
    end
    Category.generate_attributes
  end

  def verify_overall_counts
    Category.all.size.should == 12
    ProductFamily.all.size.should == 8
    ProductAttribute.all.size.should == 15
  end

  def verify_product_families
    @cat1221.product_families.size.should == 3
    @cat1222.product_families.size.should == 3
    @cat122.product_families.size.should == 4
    @cat12.product_families.size.should == 6
    @cat13.product_families.size.should == 2
    @cat1.product_families.size.should == 7
    @root.product_families.size.should == 8
  end

  # Verify the INITIAL association of attributes to categories.
  def verify_category_attributes
    category_families.keys.each do |key|
      cat = Category.find_by_name(key.to_s)
      a1 = cat.product_attributes.map {|a| a.name =~ /^attr(\d*)/ ; Integer($1)}
      a2 = category_attributes[key]
      a1.sort.should == a2.sort
    end
  end

  # Verify the INITIAL association of families to categories.
  def verify_category_families
    category_families.keys.each do |key|
      cat = Category.find_by_name(key.to_s)
      a1 = cat.product_families.map {|a| a.name =~ /^fam(\d*)/ ; Integer($1)}
      a2 = category_families[key]
      a1.sort.should == a2.sort
    end
  end

  def verify_family_attributes
    @root.product_attributes.size.should == 1
    @cat1.product_attributes.size.should == 2
    @cat2.product_attributes.size.should == 2
    @cat11.product_attributes.size.should == 8
    @cat12.product_attributes.size.should == 3
    @cat13.product_attributes.size.should == 4
    @cat121.product_attributes.size.should == 0
    @cat122.product_attributes.size.should == 5
    @cat123.product_attributes.size.should == 4
    @cat131.product_attributes.size.should == 4
    @cat1221.product_attributes.size.should == 6
    @cat1222.product_attributes.size.should == 6
  end

  # Mapping of leaf categories to their product families.  Used for the
  # INITIAL constuction of the tree.
  def leaf_category_families
    @leaf_cat_fam_map ||= { 
      :cat11 => [7],
      :cat121 => [],
      :cat1221 => [1,2,3],
      :cat1222 => [2,3,4],
      :cat123 => [2,5,6],
      :cat131 => [2,6],
      :cat2 => [8,2]
    }
  end

  # Mapping of all categories to their product families.  This adds the interior
  # categories to the leaf category families hash.  It is used for VERIFICATION
  # of the association of categories to families.
  def category_families
    @cat_fam_map ||= {
      :root => [1, 2, 3, 4, 5, 6, 7, 8],
      :cat1 => [1, 2, 3, 4, 5, 6, 7],
      :cat2 => [2, 8],
      :cat11 => [7],
      :cat12 => [1, 2, 3, 4, 5, 6],
      :cat13 => [2, 6],
      :cat121 => [],
      :cat122 => [1, 2, 3, 4],
      :cat123 => [2, 5, 6],
      :cat131 => [2, 6],
      :cat1221 => [1, 2, 3],
      :cat1222 => [2, 3, 4]
    }
  end

  # A map showing which categories have which attributes. Used for
  # VERIFICATION only.
  def category_attributes
    @cat_attr_map ||= {
      :root => [1],
      :cat1 => [1, 2],
      :cat2 => [1, 15],
      :cat11 => [1, 2, 10, 11, 12, 13, 14, 15],
      :cat12 => [1, 2, 3],
      :cat13 => [1,2, 3, 15],
      :cat121 => [],
      :cat122 => [1, 2, 3, 4, 5],
      :cat123 => [1, 2, 3, 15],
      :cat131 => [1, 2, 3, 15],
      :cat1221 => [1, 2, 3, 4, 5, 6],
      :cat1222 => [1, 2, 3, 4, 5, 15]
    }
  end

  # Mapping of product families to their attributes.
  # There are eight product families (the rows), and
  # fifteen attributes (the columns).  This is used for
  # assigning attributes to product familes.
  def family_attributes
    @fam_attr_map ||= [
      [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1],
      [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1],
      [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1]
    ]
  end

  private

  def find_or_create_product_family(j)
    name = "fam#{j}"
    iname = "@" + name
    fam = instance_variable_get(iname)
    unless fam
      fam = ProductFamily.make!(:name => name)
      instance_variable_set(iname, fam)
    end
    fam
  end

  def find_or_create_attribute(j)
    name = "attr#{j}"
    iname = "@" + name
    attr = instance_variable_get(iname)
    unless attr
      attr = ProductAttribute.make!(:name => name)
      instance_variable_set(iname, attr)
    end
    attr   
  end

end
