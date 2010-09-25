require 'spec_helper'

describe "admin/product_attributes/edit.html.erb" do
  
  before(:each) do
    assigns[:product_attribute] = mock_model(ProductAttribute).as_null_object
    assigns[:product_families] = double(Array).as_null_object
    assigns[:previous_url] = "/home/admin"
  end
  
  it "displays the Product Attributes banner" do
    render :layout => true
    response.should contain("Edit Attribute")
  end
end