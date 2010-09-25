require 'spec_helper'

describe "admin/product_attributes/_attribute_values.html.erb" do
  
  before(:each) do
    @attribute = stub_model(ProductAttribute, :atype => ProductAttribute::Atype_String)
    @attribute_range = stub_model(AttributeRange, :string_val => "Pizza", :priority => 2)
    @attribute.stub(:attribute_ranges).and_return [nil, nil, nil, nil, nil, @attribute_range]
  end
  
  it "should display a table with id 'attribute-ranges'" do
    render :locals => {:product_attribute => @attribute, :count => 16}
    response.should have_selector("table#attribute-ranges")
  end

  it "should display a table with 'Pizza' in the third row" do 
    render :locals => {:product_attribute => @attribute, :count => 16}    
    response.should have_selector("tr:nth-child(2)") do |row|
      row.should have_selector("td > input", :value =>  "Pizza")
    end
  end
  
end
