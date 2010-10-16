require 'spec_helper'

class SizeCarrier
  attr_accessor :size
end

# Return the number of references the product has in the given category. This
# method is specifically designed so that this construction will work in RSpec:
#
#   product.should have(1).refs_in_category(category_id)
#
class Product
  def refs_in_category(catid)
    cp = category_products.find(:first, :conditions => {:category_id => catid})
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

# Useful expectations:
# c.should be_a_leaf
# c.products.should have(1).product
# c.get_children.should have(1).child
# c.parent_id.should == id
# p.should have(1).refs_in_category(c)

describe Product do
  
  before(:each) do
    @root = Category.find(Category.root_id)
  end
  
  context "when root has no children" do 
    it "should be able to create an uncategorized product" do
      p = Product.make!
      p.errors.should be_empty
      Product.all.should have(1).product
      CategoryProduct.all.should be_empty
      Product.uncategorized.should have(1).product
      Product.uncategorized[0].id.should == p.id
    end
    
    it "should be able to create a categorized child product" do
       p = Product.make!
       f = ProductFamily.find(p.product_family_id)
       @root.add_family(f)
       @root.add_product(p.id)
       CategoryProduct.all.should have(1).association
       Product.uncategorized.should be_empty
    end
    
    it "should be able to remove a child product" do
      p = Product.make!
      f = ProductFamily.find(p.product_family_id)
      @root.add_family(f)
      @root.add_product(p.id)
      @root.remove_product(p.id)
      CategoryProduct.all.should be_empty 
      Product.all.should have(1).product
      Product.uncategorized.should have(1).product
    end
  end
  
  context "when root has children" do
    
    before(:each) do
      build_categories
    end
    
    it "should be able to create a categorized child product" do
       p = Product.make!
       f = ProductFamily.find(p.product_family_id)
       @cat123.add_family(f)
       @cat123.add_product(p.id)
       @cat123.products.should have(1).product
       CategoryProduct.all.should have(4).associations
       Product.uncategorized.should be_empty
    end
    
    it "should be able to remove a child product" do
      p = Product.make!
      @cat123.add_product(p.id)
      @cat123.remove_product(p.id)
      CategoryProduct.all.should be_empty 
      Product.all.should have(1).product
      Product.uncategorized.should have(1).product
    end
    
    it "should be able to add two products to a leaf" do
       p1 = Product.make!
       p2 = Product.make!
       f1 = ProductFamily.find(p1.product_family_id)
       f2 = ProductFamily.find(p2.product_family_id)
       @cat123.add_family(f1)
       @cat123.add_product(p1.id)
       @cat123.add_family(f2)
       @cat123.add_product(p2.id)
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
      p1 = Product.make!
      f1 = ProductFamily.find(p1.product_family_id)
      @cat123.add_family(f1)
      @cat123.add_product(p1.id)
      @cat123.add_product(p1.id)
      @cat123.errors.should_not be_empty
      @cat123.products.should have(1).product
    end
    
    it "should not be able to add a product to an interior node, part I" do
      p1 = Product.make!
      @cat12.add_product(p1.id)
      @cat12.errors.should_not be_empty
      @cat12.products.should be_empty
    end
    
    it "should not be able to add a product to an interior node, part II" do
      p1 = Product.make!
      p2 = Product.make!
      f1 = ProductFamily.find(p1.product_family_id)
      f2 = ProductFamily.find(p2.product_family_id)
      @cat123.add_family(f1)
      @cat123.add_product(p1.id)
      @cat123.add_family(f2)
      @cat12.add_product(p2.id)
      @cat12.errors.should_not be_empty
      @cat12.should have(1).product
    end
    
    it "should be able to add different products to two different nodes" do
      p1 = Product.make!
      p2 = Product.make!
      p3 = Product.make!
      f1 = ProductFamily.find(p1.product_family_id)
      f2 = ProductFamily.find(p2.product_family_id)
      f3 = ProductFamily.find(p3.product_family_id)
      @cat1221.add_family(f1)
      @cat1221.add_product(p1.id)
      @cat1221.add_family(f2)
      @cat1221.add_product(p2.id)
      @cat1222.add_family(f2)
      @cat1222.add_product(p2.id)
      @cat1222.add_family(f3)
      @cat1222.add_product(p3.id)
     
      @cat1221.should have(2).products
      @cat1222.should have(2).products
      @cat122.should have(3).products
      @cat12.should have(3).products
      @cat1.should have(3).products
      @root.should have(3).products
      @cat123.products.should be_empty
      @cat2.products.should be_empty
      @cat11.products.should be_empty
      
      p1.should have(1).refs_in_category(@cat1221.id)
      p2.should have(1).refs_in_category(@cat1221.id)
      p2.should have(1).refs_in_category(@cat1222.id)
      p3.should have(1).refs_in_category(@cat1222.id)
      
      p1.should have(1).refs_in_category(@cat122.id)
      p2.should have(2).refs_in_category(@cat122.id)
      p3.should have(1).refs_in_category(@cat122.id)
      
      p1.should have(1).refs_in_category(@cat12.id)
      p2.should have(2).refs_in_category(@cat12.id)
      p3.should have(1).refs_in_category(@cat12.id)
      
      p1.should have(1).refs_in_category(@cat1.id)
      p2.should have(2).refs_in_category(@cat1.id)
      p3.should have(1).refs_in_category(@cat1.id)
      
      p1.should have(1).refs_in_category(@root.id)
      p2.should have(2).refs_in_category(@root.id)
      p3.should have(1).refs_in_category(@root.id)
      
    end
    
    it "should propagate products correctly when leaf category is removed" do
      p1 = Product.make!
      f1 = ProductFamily.find(p1.product_family_id)
      @cat1221.add_family(f1)
      @cat1221.add_product(p1.id)
      @cat122.products.should have(1).product
      @cat1221.destroy
      @cat122.reload # force a reload of parent
      @cat122.products.should be_empty
      @cat12.products.should be_empty
      CategoryProduct.all.should be_empty
    end
    
    it "should propagate products correctly when interior category is removed" do
      p1 = Product.make!
      f1 = ProductFamily.find(p1.product_family_id)
      @cat1221.add_family(f1)
      @cat1221.add_product(p1.id)
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
      p1 = Product.make!
      p2 = Product.make!
      p3 = Product.make!
      f1 = ProductFamily.find(p1.product_family_id)
      f2 = ProductFamily.find(p2.product_family_id)
      f3 = ProductFamily.find(p3.product_family_id)
      @cat1221.add_family(f1)
      @cat1221.add_product p1.id
      @cat1221.add_family(f2)
      @cat1221.add_product p2.id
      @cat1222.add_family(f2)
      @cat1222.add_product p2.id
      @cat1222.add_family(f3)
      @cat1222.add_product p3.id

      p2.should have(2).refs_in_category(@cat122.id)
      @cat1221.reparent @cat12.id

      @cat12.get_children.should have(4).children
      @cat122.get_children.should have(1).child
      
      p1.should have(1).refs_in_category(@cat1221.id)
      p1.should have(0).refs_in_category(@cat122.id)
      p1.should have(1).refs_in_category(@cat12.id)
      p1.should have(1).refs_in_category(@cat1.id)
      p1.should have(1).refs_in_category(@root.id)

      p2.should have(1).refs_in_category(@cat1222.id)
      p2.should have(1).refs_in_category(@cat122.id)
      p2.should have(2).refs_in_category(@cat12.id)
      p2.should have(2).refs_in_category(@cat1.id)
      p2.should have(2).refs_in_category(@root.id)       
    end
    
    it "should reparent an internal category to an internal category" do
      p1 = Product.make!
      p2 = Product.make!
      p3 = Product.make!
      f1 = ProductFamily.find(p1.product_family_id)
      f2 = ProductFamily.find(p2.product_family_id)
      f3 = ProductFamily.find(p3.product_family_id)
      @cat131.add_family(f1)
      @cat131.add_product p1.id
      @cat11.add_family(f1)
      @cat11.add_product p1.id
      @cat121.add_family(f2)
      @cat121.add_product p2.id
      @cat1221.add_family(f2)
      @cat1221.add_product p2.id
      @cat1221.add_family(f3)
      @cat1221.add_product p3.id
      @cat131.add_family(f2)
      @cat131.add_product p2.id
      @cat131.add_family(f3)
      @cat131.add_product p3.id
      
      @cat12.reparent @cat13.id
      
      p1.should have(1).refs_in_category(@cat13.id)
      p2.should have(3).refs_in_category(@cat13.id)
      p3.should have(2).refs_in_category(@cat13.id)
    end
      
  end
  
end
