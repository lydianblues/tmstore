require 'spec_helper'

describe "admin/categories/_subcategories.html.erb" do
  
		
  before(:each) do
    @category= mock_model(Category).as_null_object
  end
  
 context "when there are no subcategories" do
    
    it "should display the 'No Product Subcategories' message" do
      @subcats = []
      render :locals => {:subcategories =>@subcats, :category => @category}
      response.should contain("There are no Subcategories.")
    end
  
  end
  
  context "there are subcategories" do
  
    before(:each) do
      @subcats = [mock_model(Category).as_null_object,
        mock_model(Category).as_null_object]
    end
    
    it "displays a table" do
      render :locals => {:subcategories =>@subcats, :category => @category}
      response.should have_selector "table"
    end
    
     it "should have a few more tests"
     
  end
  
end