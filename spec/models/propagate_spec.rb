require 'spec_helper'

describe Category do
  
  before(:each) do
    @root = Category.find(Category.root_id)
    build_all
  end
  
  it "should have correct inital structure" do
    Category.all.size.should == 12
    ProductFamily.all.size.should == 8
    ProductAttribute.all.size.should == 15
  end

end

