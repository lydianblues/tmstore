require 'spec_helper'

describe "test store environment" do
  
  it "should have correct inital structure" do
    build_store
    Category.all.size.should == 12
    ProductFamily.all.size.should == 8
    ProductAttribute.all.size.should == 15
    @cat1221.product_families.size.should == 3
    @cat1222.product_families.size.should == 3
    @cat122.product_families.size.should == 4
    @cat12.product_families.size.should == 6
    @cat13.product_families.size.should == 2
    @cat1.product_families.size.should == 7
    @root.product_families.size.should == 8
    verify_category_attributes
    verify_category_families
  end

end

