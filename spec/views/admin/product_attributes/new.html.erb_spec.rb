require 'spec_helper'

describe "admin/product_attributes/new.html.erb" do
  
  before(:each) do
    assigns[:product_attribute] = mock_model(ProductAttribute).as_null_object
  end
  
  it "displays the 'Create a new Attribute' banner" do
    render :layout => true
    response.should contain("Create a new Attribute")
  end
  
end