require 'spec_helper'

describe "admin/categories/_families.html.erb" do
  
  before(:each) do
    @category= mock_model(Category).as_null_object
  end
  
 context "when there are no product families" do
    
    it "should display the 'No Product Families' message" do
      @families = []
      render :locals => {:category => @category, :families => @families}
      response.should contain("There are no Product Families.")
    end
  
  end
  
  context "there are product families" do
  
    before(:each) do
      @families = [mock_model(ProductFamily).as_null_object,
        mock_model(ProductFamily).as_null_object]
    end
    
    it "displays a table" do
      render :locals => {:category => @category, :families => @families}
      response.should have_selector "table"
    end
    
     it "should have a few more tests"
     
  end
  
end
