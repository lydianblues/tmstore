require 'spec_helper'

describe "admin/product_attributes/_attribute.html.erb" do
  
  before(:each) do
    @attribute = stub_model(ProductAttribute)
    @product_family = mock_model(ProductFamily)
  end

  it "should show add, remove, delete, and edit operations" do 
    @operations = %w[edit delete add remove]
    render :locals => {:attribute => @attribute,
      :product_family => @product_family, :operations => @operations }
      
    response.should have_selector("input", :id => "delete-attribute")
    response.should have_selector("input", :id => "edit-attribute")
    response.should have_selector("input", :id => "add-attribute")
    response.should have_selector("input", :id => "remove-attribute")   
   
  end
  
  it "should show delete and edit operations, but not add and remove" do 
    @operations = %w[delete edit]
    
    render :locals => {:attribute => @attribute,
      :product_family => @product_family, :operations => @operations }
      
    response.should have_selector("input", :id => "delete-attribute")
    response.should have_selector("input", :id => "edit-attribute")
    response.should_not have_selector("input", :id => "add-attribute")
    response.should_not have_selector("input", :id => "remove-attribute")   
   
  end
  
  
end
