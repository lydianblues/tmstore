require 'spec_helper'

describe ProductAttribute do
  
  before(:each) do
    @root = Category.find(Category.root_id)
    @cat1 = Factory(:category, :parent_id => @root.id )
    @cat2 = Factory(:category, :parent_id => @root.id )
    @cat11 = Factory(:category, :parent_id => @cat1.id )
    @cat12 = Factory(:category, :parent_id => @cat1.id )
    @cat13 = Factory(:category, :parent_id => @cat1.id )
    @cat121 = Factory(:category, :parent_id => @cat12.id )
    @cat122 = Factory(:category, :parent_id => @cat12.id )
    @cat123 = Factory(:category, :parent_id => @cat12.id )
    @cat131 = Factory(:category, :parent_id => @cat13.id )
    @cat1221 = Factory(:category, :parent_id => @cat122.id )
    @cat1222 = Factory(:category, :parent_id => @cat122.id )
    
    @f1 = Factory(:product_family)
    @f2 = Factory(:product_family)
    @a1 = Factory(:product_attribute)
    @a2 = Factory(:product_attribute)
    @a3 = Factory(:product_attribute)
  end
  
#
# Category tree for the examples:
#  
#                        /\
#                      /   \
#                     1     2
#                    /|\
#                  /  |  \
#                /    |   \
#              11    12    13
#                    /|\     \
#                  /  | \     \
#                /    |  \     \ 
#              121   122  123  131
#                    /\
#                  /   \
#                /      \
#             1221     1222
#
 
  it "propagates when adding attribute to family first, propagation flag false" do    
    @f1.add_attribute(@a1, false)
    @cat1221.add_family(@f1.id)
    
    @cat1221.product_attributes.should have(1).attribute
    CategoryAttribute.find(:all).should have(5).elements
    @cat122.product_attributes.should have(1).attribute
    @cat12.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
  end
  
  it "propagates when adding family to category first with propagation" do  
      @cat1221.add_family(@f1.id)
      @f1.add_attribute(@a1, true)
      
      CategoryAttribute.find(:all).should have(5).elements
      @cat1221.product_attributes.should have(1).attribute
      @cat122.product_attributes.should have(1).attribute
      @cat12.product_attributes.should have(1).attribute
      @cat1.product_attributes.should have(1).attribute
      @cat1.product_attributes.should have(1).attribute
  end
  
  it "propagates when adding family to category first with explicit propagation" do
      @cat1221.add_family(@f1.id)
      @f1.add_attribute(@a1, false)
      @cat1221.generate_attributes_up
      
      CategoryAttribute.find(:all).should have(5).elements
      @cat1221.product_attributes.should have(1).attribute
      @cat122.product_attributes.should have(1).attribute
      @cat12.product_attributes.should have(1).attribute
      @cat1.product_attributes.should have(1).attribute
      @cat1.product_attributes.should have(1).attribute
  end
  
  it "propagates when same product family associated to two categories" do
    @f1.add_attribute(@a1, false)  
    @cat1221.add_family(@f1.id)
    @cat1222.add_family(@f1.id)
    
    CategoryAttribute.find(:all).should have(6).elements
    @cat1221.product_attributes.should have(1).attribute
    @cat1222.product_attributes.should have(1).attribute
    @cat122.product_attributes.should have(1).attribute
    @cat12.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
     
  end
  
  it "propagates when same product family associated to three categories" do
    @f1.add_attribute(@a1, false)  
    @cat1221.add_family(@f1.id)
    @cat1222.add_family(@f1.id)
    @cat131.add_family(@f1.id)
    
    CategoryAttribute.find(:all).should have(8).elements
    @cat1221.product_attributes.should have(1).attribute
    @cat1222.product_attributes.should have(1).attribute
    @cat122.product_attributes.should have(1).attribute
    @cat12.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
    @cat131.product_attributes.should have(1).attribute
    @cat13.product_attributes.should have(1).attribute
  end
  
  it "propagates when same attribute in two families" do
    @f1.add_attribute(@a1, false)
    @f2.add_attribute(@a1, false)  
    @cat1221.add_family(@f1.id)
    @cat1222.add_family(@f2.id)
    @cat131.add_family(@f2.id)

    CategoryAttribute.find(:all).should have(8).elements
    @cat1221.product_attributes.should have(1).attribute
    @cat1222.product_attributes.should have(1).attribute
    @cat122.product_attributes.should have(1).attribute
    @cat12.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
    @cat131.product_attributes.should have(1).attribute
    @cat13.product_attributes.should have(1).attribute
  end
   
  it "propagates when one leaf child has no product families" do
    @f1.add_attribute(@a1, false)
    @cat1221.add_family(@f1.id)
    CategoryAttribute.find(:all).should have(5).elements
    @cat1222.add_family(@f2.id)
    @cat1222.product_attributes.should be_empty
    @cat122.product_attributes.should be_empty
    CategoryAttribute.find(:all).should have(1).elements
  end
   
  it "propagates when two families have common attributes" do
    @f1.add_attribute(@a1, false)
    @f1.add_attribute(@a2, false) 
    @f2.add_attribute(@a2, false)
    @f2.add_attribute(@a3, false) 
    @cat1221.add_family(@f1.id)
    @cat1222.add_family(@f2.id)
    @cat131.add_family(@f2.id)

    CategoryAttribute.find(:all).should have(12).elements
    @cat1221.product_attributes.should have(2).attribute
    @cat1222.product_attributes.should have(2).attribute
    @cat122.product_attributes.should have(1).attribute
    @cat12.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
    @cat131.product_attributes.should have(2).attribute
    @cat13.product_attributes.should have(2).attribute
    @cat11.product_attributes.should be_empty
    @cat2.product_attributes.should be_empty
    @root.product_attributes.should have(1).attribute
  end
  
  it "propagates with reparent, part I" do
    @f1.add_attribute(@a1, false)
    @f1.add_attribute(@a2, false) 
    @f2.add_attribute(@a2, false)
    @f2.add_attribute(@a3, false) 
    @cat1221.add_family(@f1.id)
    @cat1222.add_family(@f2.id)
    @cat131.add_family(@f2.id)
    
    @cat122.reparent(@cat11.id)

    CategoryAttribute.find(:all).should have(12).elements
    @cat1221.product_attributes.should have(2).attribute
    @cat1222.product_attributes.should have(2).attribute
    @cat122.product_attributes.should have(1).attribute
    @cat12.product_attributes.should be_empty
    @cat1.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
    @cat131.product_attributes.should have(2).attribute
    @cat13.product_attributes.should have(2).attribute
    @cat11.product_attributes.should have(1).attributes
    @cat2.product_attributes.should be_empty
    @root.product_attributes.should have(1).attribute
  end
  
  it "propagates with reparent, part II" do
    @f1.add_attribute(@a1, false)
    @f1.add_attribute(@a2, false) 
    @f2.add_attribute(@a2, false)
    @f2.add_attribute(@a3, false) 
    @cat1221.add_family(@f1.id)
    @cat1222.add_family(@f2.id)
    @cat131.add_family(@f2.id)
    
    @cat122.reparent(@cat13.id)

    CategoryAttribute.find(:all).should have(10).elements
    @cat1221.product_attributes.should have(2).attribute
    @cat1222.product_attributes.should have(2).attribute
    @cat13.product_attributes.should have(1).attribute
    @cat122.product_attributes.should have(1).attribute
    @cat12.product_attributes.should be_empty
    @cat1.product_attributes.should have(1).attribute
    @cat1.product_attributes.should have(1).attribute
    @cat131.product_attributes.should have(2).attribute
    @cat13.product_attributes.should have(1).attribute
    @cat11.product_attributes.should be_empty
    @cat2.product_attributes.should be_empty
    @root.product_attributes.should have(1).attribute
  end
  
  it "propagates when two familes on the same leaf" do
    @f1.add_attribute(@a1, false)
    @f1.add_attribute(@a2, false) 
    @f2.add_attribute(@a2, false)
    @f2.add_attribute(@a3, false)
    
    @cat1221.add_family(@f1.id)
    CategoryAttribute.find(:all).should have(10).elements
    @cat1221.add_family(@f2.id)
    CategoryAttribute.find(:all).should have(5).elements
    @cat1221.product_attributes.should have(1).attribute
  end
  
end
      