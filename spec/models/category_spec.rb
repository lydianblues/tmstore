require 'spec_helper'

describe Category do
  
  before(:each) do
    @root = Category.find(Category.root_id)
  end
  
  context "when root has no children" do
    it "should be a leaf with correct pathname" do
      @root.should be_a_leaf
      @root.full_path.should == "/"
    end
    
    it "should allow associating a product family" do
      fam = ProductFamily.make!
      @root.add_family(fam)
      @root.should have(1).product_families
    end
    
    it "should create a category given valid attributes" do
      cat = Category.make!(:parent_id => @root.id)
      Category.find(:all).should have(2).categories
      cat.full_path.should == "/#{cat.name}"
    end
  end
  
  context "when example categories have been built" do
    before(:each) do
      build_categories
    end
  
    it "should identify leaf and non-leaf categories" do
      @root.should_not be_a_leaf
      @cat1.should_not be_a_leaf
      @cat2.should be_a_leaf
      @cat11.should be_a_leaf
      @cat12.should_not be_a_leaf
      @cat13.should_not be_a_leaf
      @cat121.should be_a_leaf
      @cat122.should_not be_a_leaf
      @cat123.should be_a_leaf
      @cat131.should be_a_leaf
      @cat1221.should be_a_leaf
      @cat1222.should be_a_leaf
    end
    
    it "should correctly map categories to pathnames" do
      cat_paths.each do |p|
        p[1].full_path.should == p[0]
      end
    end
    
    it "should correctly map pathnames to categories" do
      cat_paths.each do |p|
        Category.path_to_id(p[0]).should == p[1].id
      end
    end

    it "should handle a long path" do
      # Note with Oracle, the maximum concatenated string length is 4000
      # characters.  "head" is the first category created under the parent,
      # "last" is the last category in the created path. "path" is the full
      # path from the root to last.
      path, head, last = build_long_path(@root, 500)
      Category.path_to_id(path).should == last.id
      last.full_path.should == path
      last.get_depth.should == 500
      @root.get_descendents.size.should == 512
      head.reparent(@cat122)
      last.get_depth.should == 503
      last.full_path.should == @cat122.full_path + path
      @cat122.get_descendents.size.should == 503
    end

    it "should correctly delete interior category" do
      @cat12.destroy
      refresh_category_refs
      Category.all.should have(11).categories
      @cat121.parent_id.should == @cat1.id
      @cat122.parent_id.should == @cat1.id
      @cat123.parent_id.should == @cat1.id
      Category.children(@cat1.id).size.should == 5
    end
    
    it "should correctly delete leaf category" do
      @cat131.destroy
      Category.all.should have(11).categories
      @cat13.get_children.should be_empty # using direct access to database
      Category.children(@cat13.id).should be_empty # using a scope
    end

    context "when leaf is only child of its parent" do
      
      it "should delete leaf category and preserve " +  
        "associated product familes from parent" do
        pf = ProductFamily.make!
        @cat131.add_family(pf)

        @cat13.product_families.should have(1).product_familes
        @cat131.product_families.should have(1).product_familes

        @cat131.destroy
        @cat13 = @cat13.refresh

        Category.all.should have(11).categories
        @cat13.get_children.should be_empty
        @cat13.product_families.should have(1).product_family
      end

     it "should delete leaf category and preserve " +  
        "associated products in parent" do
        prod = Product.make!
        fam = ProductFamily.find(prod.product_family_id)
        @cat131.add_family(fam)
        @cat131.add_product(prod)

        @cat13.product_families.should have(1).product_familes
        @cat131.product_families.should have(1).product_familes
        @cat13.products.should have(1).products
        @cat131.products.should have(1).products

        @cat131.destroy
        @cat13 = @cat13.refresh

        @cat13.get_children.should be_empty
        @cat13.product_families.should have(1).product_family
        @cat13.products.should have(1).product
      end

      it "should delete leaf category and associated " +  
        "product attributes in parent" do
        prod = Product.make!
        fam = prod.product_family
        fam.add_attribute(ProductAttribute.make!)
        @cat131.add_family(fam)
        @cat131.add_product(prod)

        @cat13.product_attributes.should have(1).product_attribute
        @cat131.product_attributes.should have(1).product_attribute

        @cat131.destroy
        @cat13 = @cat13.refresh

        @cat13.product_attributes.should have(1).product_attribute
      end
    end

    context "when parent has more than one child" do
      it "should delete leaf category and remove product families " +  
        "from parent not contributed by some other child, one product family" do
        pf = ProductFamily.make!
        @cat1221.add_family(pf)
        @cat1222.add_family(pf)

        @cat122.product_families.should have(1).product_familes

        @cat1221.destroy
        @cat122 = Category.find(@cat122) # reload category

        Category.all.should have(11).categories
        @cat122.product_families.should have(1).product_family
        @cat1222.product_families.should have(1).product_family
      end

      it "should delete leaf category and remove product families from " +  
        "parent not contributed by some other child, four product families" do
        pf1 = ProductFamily.make!
        pf2 = ProductFamily.make!
        pf3 = ProductFamily.make!
        pf4 = ProductFamily.make!
        @cat1221.add_family([pf1, pf2, pf3])
        @cat1222.add_family([pf2, pf3, pf4])

        @cat122.product_families.should have(4).product_familes

        @cat1221.destroy
        @cat122 = Category.find(@cat122) # reload category

        @cat122.product_families.should have(3).product_families
        @cat1222.product_families.should have(3).product_families
      end

      it "should delete leaf category and remove product families from " +  
        "parent not contributed by some other child, five product families" do
        pf1 = ProductFamily.make!
        pf2 = ProductFamily.make!
        pf3 = ProductFamily.make!
        pf4 = ProductFamily.make!
        pf5 = ProductFamily.make!
        @cat11.add_family(pf5)
        @cat1221.add_family([pf1, pf2, pf3])
        @cat1222.add_family([pf2, pf3, pf4])

        @cat1.product_families.should have(5).product_familes

        @cat1221.destroy
        @cat1 = Category.find(@cat1) # reload category
        @cat1.product_families.should have(4).product_families
      end
    end
    
    it "should not be able to reparent an interior node to a leaf node" do
      @cat12.reparent(@cat2)
      @cat12.errors.full_messages.should_not be_empty
      refresh_category_refs
      @cat12.parent_id.should == @cat1.id # unchanged
      @cat1.get_children.should have(3).subcategories
      @cat2.get_children.should have(0).subcategories
    end

    it "should not be able to reparent a leaf node to a leaf node" do
      @cat11.reparent(@cat2)
      @cat11.errors.full_messages.should_not be_empty
      refresh_category_refs
      @cat11.parent_id.should == @cat1.id # unchanged
      @cat1.get_children.should have(3).subcategories
      @cat2.get_children.should have(0).subcategories
    end

    it "should not be able to reparent a node to one of its own descendents" do
      @cat1.reparent(@cat122)      
      @cat1.errors.full_messages.should_not be_empty
      refresh_category_refs
      @cat1.parent_id.should == @root.id # unchanged
      @root.get_children.should have(2).subcategories
      @cat122.get_children.should have(2).subcategories
    end

    it "should correctly reparent an interior node to an interior node" do
      @cat122.reparent(@cat13)
      @cat122.parent_id.should == @cat13.id
      @cat13.get_children.should have(2).subcategories
      Category.children(@cat13.id).should have(2).subcategories
    end

    it "should not be able to add product family to root category " + 
      "when it has descendents" do
      fam = ProductFamily.make!
      @root.add_family(fam)
      @root.should have(0).product_families
      @root.errors.should_not be_empty
    end
 
    # Check that the merge_families when called on a leaf node
    # removes all the product families from that node.
    it "merge_families should empty leaf node that has a product family" do
      fam = ProductFamily.make!
      @cat131.add_family(fam)
      @cat131.errors.should be_empty
      @cat131.product_families.size.should == 1
      @cat131.merge_families
      @cat131.errors.should be_empty
      @cat131 = Category.find(@cat131.id) # refresh
      @cat131.product_families.should be_empty
    end

    it "merge_families should not change a leaf node that has no product families" do
      @cat131.product_families.should be_empty
      @cat131.merge_families
      @cat131.errors.should be_empty
      @cat131.product_families.should be_empty
    end

    # Check that the merge_products when called on a leaf node
    # removes all the products from that node.
    it "merge_products should empty leaf node that has a product" do
      prod = Product.make!
      fam = prod.product_family
      @cat131.products.should be_empty
      @cat131.add_family(fam)
      @cat131.errors.should be_empty
      @cat131.product_families.size.should == 1
      @cat131.add_product(prod)
      @cat131.errors.should be_empty
      @cat131.products.size.should == 1
      @cat131.merge_products
      @cat131 = Category.find(@cat131.id) # refresh
      @cat131.errors.should be_empty
      @cat131.products.should be_empty
    end

    it "merge_products should not change a leaf node that has no products" do
      @cat131.products.should be_empty
      @cat131.merge_products
      @cat131.errors.should be_empty
      @cat131.products.should be_empty
    end

    
  end 
end
