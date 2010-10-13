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
      @root.add_family(fam.id)
      @root.should have(1).product_families
    end
    
    it "should create a category given valid attributes" do
      cat = Category.make!(:parent_id => @root.id)
      Category.find(:all).should have(2).categories
      cat.full_path.should == "/#{cat.name}"
    end
  end
  
  context "when example tree has been built" do
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
    
   it "should generate correct pathnames" do
      @cat1.full_path.should == "/#{@cat1.name}"
      @cat2.full_path.should == "/#{@cat2.name}"
      @cat11.full_path.should == "/#{@cat1.name}/#{@cat11.name}"
      @cat12.full_path.should == "/#{@cat1.name}/#{@cat12.name}"
      @cat13.full_path.should == "/#{@cat1.name}/#{@cat13.name}"
      @cat121.full_path.should == 
        "/#{@cat1.name}/#{@cat12.name}/#{@cat121.name}"
      @cat122.full_path.should ==
        "/#{@cat1.name}/#{@cat12.name}/#{@cat122.name}"
      @cat123.full_path.should == 
        "/#{@cat1.name}/#{@cat12.name}/#{@cat123.name}"
      @cat131.full_path.should == 
        "/#{@cat1.name}/#{@cat13.name}/#{@cat131.name}"
      @cat1221.full_path.should ==
        "/#{@cat1.name}/#{@cat12.name}/#{@cat122.name}/#{@cat1221.name}"
      @cat1222.full_path.should ==
        "/#{@cat1.name}/#{@cat12.name}/#{@cat122.name}/#{@cat1222.name}"
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
        @cat131.add_family(pf.id)

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
        @cat131.add_family(prod.product_family_id)
        @cat131.add_product(prod.id)

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
        @cat131.add_family(fam.id)
        @cat131.add_product(prod.id)

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
        @cat1221.add_family(pf.id)
        @cat1222.add_family(pf.id)

        @cat122.product_families.should have(1).product_familes

        @cat1221.destroy
        @cat122 = Category.find(@cat122) # reload category

        Category.all.should have(11).categories
        @cat122.product_families.should have(1).product_family
        @cat1222.product_families.should have(1).product_family
      end

      it "should delete leaf category and remove product families " +  
        "from parent not contributed by some other child, four product families" do
        pf1 = ProductFamily.make!
        pf2 = ProductFamily.make!
        pf3 = ProductFamily.make!
        pf4 = ProductFamily.make!
        @cat1221.add_family(pf1.id)
        @cat1221.add_family(pf2.id)
        @cat1221.add_family(pf3.id)
        @cat1222.add_family(pf2.id)
        @cat1222.add_family(pf3.id)
        @cat1222.add_family(pf4.id)

        @cat122.product_families.should have(4).product_familes

        @cat1221.destroy
        @cat122 = Category.find(@cat122) # reload category

        @cat122.product_families.should have(3).product_families
        @cat1222.product_families.should have(3).product_families
      end

      it "should delete leaf category and remove product families " +  
        "from parent not contributed by some other child, five product families" do
        pf1 = ProductFamily.make!
        pf2 = ProductFamily.make!
        pf3 = ProductFamily.make!
        pf4 = ProductFamily.make!
        pf5 = ProductFamily.make!
        @cat11.add_family(pf5.id)
        @cat1221.add_family(pf1.id)
        @cat1221.add_family(pf2.id)
        @cat1221.add_family(pf3.id)
        @cat1222.add_family(pf2.id)
        @cat1222.add_family(pf3.id)
        @cat1222.add_family(pf4.id)

        @cat1.product_families.should have(5).product_familes

        @cat1221.destroy
        @cat1 = Category.find(@cat1) # reload category
        @cat1.product_families.should have(4).product_families
      end
    end
    
    it "should not be able to reparent an interior node to a leaf node" do
      @cat12.reparent(@cat2.id)
      @cat12.errors.full_messages.should_not be_empty
      refresh_category_refs
      @cat12.parent_id.should == @cat1.id # unchanged
      @cat1.get_children.should have(3).subcategories
      @cat2.get_children.should have(0).subcategories
    end

    it "should not be able to reparent a leaf node to a leaf node" do
      @cat11.reparent(@cat2.id)
      @cat11.errors.full_messages.should_not be_empty
      refresh_category_refs
      @cat11.parent_id.should == @cat1.id # unchanged
      @cat1.get_children.should have(3).subcategories
      @cat2.get_children.should have(0).subcategories
    end

    it "should not be able to reparent a node to one of its own descendents" do
      @cat1.reparent(@cat122.id)      
      @cat1.errors.full_messages.should_not be_empty
      refresh_category_refs
      @cat1.parent_id.should == @root.id # unchanged
      @root.get_children.should have(2).subcategories
      @cat122.get_children.should have(2).subcategories
    end

    it "should correctly reparent an interior node to an interior node" do
      @cat122.reparent(@cat13.id)
      @cat122.parent_id.should == @cat13.id
      @cat13.get_children.should have(2).subcategories # direct access to database
      Category.children(@cat13.id).should have(2).subcategories # active record scope
    end

    it "should not be able to add product family to root category " + 
      "when it has descendents" do
      fam = ProductFamily.make!
      @root.add_family(fam.id)
      @root.should have(0).product_families
      @root.errors.should_not be_empty
    end
 
    # Check that the merge_families when called on a leaf node
    # removes all the product families from that node.
    it "merge_families should empty leaf node that has a product family" do
      fam = ProductFamily.make!
      @cat131.add_family(fam.id)
      @cat131.errors.should be_empty
      @cat131.product_families.size.should == 1
      @cat131.merge_families
      @cat131.errors.should be_empty
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
      @cat131.add_family(fam.id)
      @cat131.errors.should be_empty
      @cat131.product_families.size.should == 1
      @cat131.add_product(prod.id)
      @cat131.errors.should be_empty
      @cat131.products.size.should == 1
      @cat131.merge_products
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
