require 'spec_helper'

	
describe "admin/categories/_attributes.html.erb" do
  
  before(:each) do
    @attributes = [mock_model(ProductAttribute).as_null_object,
      mock_model(ProductAttribute).as_null_object]
  end
  
 context "when there are no product attributes" do
    
    it "should display the 'No Product Attributes' message" do
      @attributes = []
      render :locals => {:attributes => @attributes}
      response.should contain("There are no Product Attributes.")
    end
  
  end
  
  context "there are product attributes" do
  
     before(:each) do
       @attributes = [mock_model(ProductAttribute).as_null_object,
         mock_model(ProductAttribute).as_null_object]
     end
    
    it "displays a table" do
      render :locals => {:attributes => @attributes}
      response.should have_selector "table"
    end
    
    it "should have a few more tests"
    
  end
  
end