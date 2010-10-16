require 'spec_helper'

describe ProductAttribute do
  
  before(:each) do
    build_store
    # Other unassociated families and attributes.
    @f1 = ProductFamily.make!
    @f2 = ProductFamily.make!
    @a1 = ProductAttribute.make!
    @a2 = ProductAttribute.make!
    @a3 = ProductAttribute.make!
  end

  it "add empty family to leaf category, all product attributes will be removed" do
    @cat1221.add_family(@f1)
    @cat1221.product_attributes.should be_empty
    @cat122.product_attributes.should be_empty
    @cat12.product_attributes.should be_empty
    @cat1.product_attributes.should be_empty
    @root.product_attributes.should be_empty
  end
  
  it "propagates when adding family to category, then attribute to family" do  
    @cat121.add_family(@f1)
    @cat121.product_attributes.should be_empty
    @f1.add_attribute(@a1)
    @cat121.product_attributes.should have(1).element
    @cat12.product_attributes.should be_empty
  end

  it "propagates when adding attribute to family, then family to category" do    
    @f1.add_attribute(@a1)
    @cat1221.add_family(@f1)
    @cat1221 = Category.find(@cat1221.id)
    @cat1221.product_attributes.should have(7).attributes
    CategoryAttribute.all.should have(15).attributes
    @cat122.product_attributes.should have(6).attribute
  end
  
  it "propagates when removing attribute from family" do    
    @f1.add_attribute(@a1, false)
    @cat1221.add_family(@f1.id)

    @f1.remove_attribute(@a1.id, true)

    @cat1221.product_attributes.should have(0).attributes
    CategoryAttribute.all.should have(0).attributes
    @cat122.product_attributes.should have(0).attributes
    @cat12.product_attributes.should have(0).attributes
    @cat1.product_attributes.should have(0).attributes
    @cat1.product_attributes.should have(0).attributes
  end

  it "does nothing when trying to remove an attribute not in the family" do
    @f1.remove_attribute(@a1.id, true)
    @f1.errors.full_messages.should be_empty
  end
  
  it "propagates when adding family to category first, manual propagation" do
      @cat1221.add_family(@f1.id)
      @f1.add_attribute(@a1, false)
      @cat1221.generate_attributes_up
      
      CategoryAttribute.all.should have(5).elements
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
    
    CategoryAttribute.all.should have(6).elements
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
    
    CategoryAttribute.all.should have(8).elements
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

    CategoryAttribute.all.should have(8).elements
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
    CategoryAttribute.all.should have(5).elements
    @cat1222.add_family(@f2.id)
    @cat1222.product_attributes.should be_empty
    @cat122.product_attributes.should be_empty
    CategoryAttribute.all.should have(1).elements
  end
   
  it "propagates when two families have common attributes" do
    @f1.add_attribute(@a1, false)
    @f1.add_attribute(@a2, false) 
    @f2.add_attribute(@a2, false)
    @f2.add_attribute(@a3, false) 
    @cat1221.add_family(@f1.id)
    @cat1222.add_family(@f2.id)
    @cat131.add_family(@f2.id)

    CategoryAttribute.all.should have(12).elements
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
    
    @cat122.reparent(@cat13.id)

    @cat122.errors.full_messages.should be_empty
    CategoryAttribute.all.should have(10).attributes
    @cat1221.product_attributes.should have(2).attribute
    @cat1222.product_attributes.should have(2).attribute
    @cat122.product_attributes.should have(1).attribute
    @cat12.product_attributes.should be_empty
    @cat1.product_attributes.should have(1).attribute
    @cat131.product_attributes.should have(2).attribute
    @cat13.product_attributes.should have(1).attribute
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

    CategoryAttribute.all.should have(10).elements
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
  
  it "propagates when two families on the same leaf" do
    @f1.add_attribute(@a1, false)
    @f1.add_attribute(@a2, false) 
    @f2.add_attribute(@a2, false)
    @f2.add_attribute(@a3, false)

    @cat1221.add_family(@f1.id)

    CategoryAttribute.all.should have(10).elements
    @cat1221.add_family(@f2.id)
    CategoryAttribute.all.should have(5).elements
    @cat1221.product_attributes.should have(1).attribute
  end
  
end
      
