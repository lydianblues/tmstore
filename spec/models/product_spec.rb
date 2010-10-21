require 'spec_helper'

class SizeCarrier
  attr_accessor :size
end

# Return the number of references the product has in the given category. This
# method is specifically designed so that this construction will work in RSpec:
#
#   product.should have(1).refs_in_category(category)
#

class Product
  def refs_in_category(cat)
    cp = CategoryProduct.where(:category_id => cat.id, :product_id => self.id).first
    if cp
      ref_count = cp.ref_count
    else
      ref_count = 0
    end
    # return something that responds to 'size' and returns the ref count.
    sc = SizeCarrier.new
    sc.size = ref_count
    sc
  end
end

class Category
  def add_product_with_family(prod)
    add_family(prod.product_family)
    add_product(prod)
  end
end

# Other useful expectations:
# c.should be_a_leaf
# c.products.should have(1).product
# c.get_children.should have(1).child
# c.parent_id.should == id

# Note: an "uncategorized product" means a product not associated with any category.

describe Product do
  
    context "when root has no children" do 
    before(:each) do
      @root = Category.find(Category.root_id)
      @prod = Product.make!
    end
  
    it "should be able to create an uncategorized product" do
      Product.all.should have(1).product
      CategoryProduct.all.should be_empty
      Product.uncategorized.should have(1).product
      Product.uncategorized[0].id.should == @prod.id
    end
    
    it "should be able to create a categorized child product" do
      @root.add_product_with_family(@prod)
      CategoryProduct.all.should have(1).association
      Product.uncategorized.should be_empty
    end
    
    it "should be able to remove a child product" do
      @root.add_product_with_family(@prod)
      Product.uncategorized.should have(0).products
      @root.remove_product(@prod.id)
      CategoryProduct.all.should be_empty 
      Product.all.should have(1).product
      Product.uncategorized.should have(1).product
    end

   it "should not be able to add the same product twice" do
      @root.add_product_with_family(@prod)
      @root.errors.full_messages.should be_empty
      @root.add_product(@prod)
      @root.errors.full_messages.should_not be_empty
   end

   it "should not be able to add product without product family" do
      @root.add_product(@prod)
      @root.errors.full_messages.should_not be_empty
   end

  end
  
  context "when root has children" do
    
    before(:each) do
      build_categories
      @p1 = Product.make!
      @p2 = Product.make!
      @p3 = Product.make!
      @f1 = @p1.product_family
      @f2 = @p2.product_family
      @f3 = @p3.product_family
    end
    
    it "should be able to create a categorized child product" do
      @cat123.add_product_with_family(@p1)
      @cat123.products.should have(1).product
      CategoryProduct.all.should have(4).associations
      Product.uncategorized.should have(2).categories
    end
    
    it "should be able to remove a child product" do
      @cat123.add_product_with_family(@p1)
      @cat123.remove_product(@p1.id)
      CategoryProduct.all.should be_empty 
      Product.all.should have(3).products
      Product.uncategorized.should have(3).products
    end
    
    it "should be able to add two products to a leaf" do
      @cat123.add_product_with_family(@p1)
      @cat123.add_product_with_family(@p2)
      
      @cat12.products.should have(2).products
      [@cat123, @cat12, @cat1, @root].each do |cat|
        cat.products.should have(2).products
      end
      [@cat2, @cat11, @cat13, @cat121, @cat122, @cat131,
       @cat1221, @cat1222].each do |cat|
        cat.products.should be_empty
      end
    end
    
    it "should not be able to add a product to a leaf twice" do
      @cat123.add_family(@f1)
      @cat123.add_product(@p1)
      @cat123.add_product(@p1)
      @cat123.errors.should_not be_empty
      @cat123.products.should have(1).product
    end
    
    it "should not be able to add a product to an interior node, part I" do
      @cat12.add_product(@p1)
      @cat12.errors.should_not be_empty
      @cat12.products.should be_empty
    end
    
    it "should not be able to add a product to an interior node, part II" do
      @cat123.add_product_with_family(@p2)
      @cat123.add_family(@f2)
      @cat12.add_product(@p2)
      @cat12.errors.should_not be_empty
      @cat12.should have(1).product
    end
    
    it "should be able to add different products to two different nodes" do
      @cat1221.add_product_with_family(@p1)
      @cat1221.add_product_with_family(@p2)
      @cat1222.add_product_with_family(@p2)
      @cat1222.add_product_with_family(@p3)
     
      @cat1221.should have(2).products
      @cat1222.should have(2).products
      @cat122.should have(3).products
      @cat12.should have(3).products
      @cat1.should have(3).products
      @root.should have(3).products
      @cat123.products.should be_empty
      @cat2.products.should be_empty
      @cat11.products.should be_empty
      
      @p1.should have(1).refs_in_category(@cat1221)
      @p2.should have(1).refs_in_category(@cat1221)
      @p2.should have(1).refs_in_category(@cat1222)
      @p3.should have(1).refs_in_category(@cat1222)
      
      @p1.should have(1).refs_in_category(@cat122)
      @p2.should have(2).refs_in_category(@cat122)
      @p3.should have(1).refs_in_category(@cat122)
      
      @p1.should have(1).refs_in_category(@cat12)
      @p2.should have(2).refs_in_category(@cat12)
      @p3.should have(1).refs_in_category(@cat12)
      
      @p1.should have(1).refs_in_category(@cat1)
      @p2.should have(2).refs_in_category(@cat1)
      @p3.should have(1).refs_in_category(@cat1)
      
      @p1.should have(1).refs_in_category(@root)
      @p2.should have(2).refs_in_category(@root)
      @p3.should have(1).refs_in_category(@root)
      
    end
    
    it "should propagate products correctly when leaf category is removed" do
      @cat1221.add_product_with_family(@p1)
      @cat122.products.should have(1).product
      @cat1221.destroy
      @cat122.reload # force a reload of parent
      @cat122.products.should be_empty
      @cat12.products.should be_empty
      CategoryProduct.all.should be_empty
    end
    
    it "should propagate products correctly when interior category is removed" do
      @cat1221.add_product_with_family(@p1)
      @cat122.should have(1).product
      @cat12.destroy
      @cat122.reload # force a reload of child
      @cat122.parent_id.should == @cat1.id
      @cat122.should have(1).product
      @cat1221.should have(1).product
      @cat1.should have(1).product
      @root.should have(1).product
    end
    
    it "should reparent a leaf to an internal category" do
      @cat1221.add_product_with_family(@p1)
      @cat1221.add_product_with_family(@p2)
      @cat1222.add_product_with_family(@p2)
      @cat1222.add_product_with_family(@p3)

      @p2.should have(2).refs_in_category(@cat122)
      @cat1221.reparent(@cat12)
      @cat1221.errors.should be_empty
      @cat12.get_children.should have(4).children
      @cat122.get_children.should have(1).child
      
      @p1.should have(1).refs_in_category(@cat1221)
      @p1.should have(0).refs_in_category(@cat122)
      @p1.should have(1).refs_in_category(@cat12)
      @p1.should have(1).refs_in_category(@cat1)
      @p1.should have(1).refs_in_category(@root)

      @p2.should have(1).refs_in_category(@cat1222)
      @p2.should have(1).refs_in_category(@cat122)
      @p2.should have(2).refs_in_category(@cat12)
      @p2.should have(2).refs_in_category(@cat1)
      @p2.should have(2).refs_in_category(@root)       
    end
    
    it "should reparent an internal category to an internal category" do
      @cat1221.add_product_with_family(@p2)
      @cat1221.add_product_with_family(@p3)
      @cat11.add_product_with_family(@p1)
      @cat121.add_product_with_family(@p2)
      @cat131.add_product_with_family(@p1)
      @cat131.add_product_with_family(@p2)
      @cat131.add_product_with_family(@p3)

      @cat12.reparent(@cat13)
      
      @p1.should have(1).refs_in_category(@cat13)
      @p2.should have(3).refs_in_category(@cat13)
      @p3.should have(2).refs_in_category(@cat13)
    end
      
  end
  
end
