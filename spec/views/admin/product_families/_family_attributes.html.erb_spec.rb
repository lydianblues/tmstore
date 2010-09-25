require 'spec_helper'

describe "admin/product_families/_family_attributes.html.erb" do
  
  before(:each) do
    @product_family = mock_model(ProductFamily).as_null_object
    product_attribute_1 = mock_model(ProductAttribute).as_null_object
    product_attribute_2 = mock_model(ProductAttribute).as_null_object
    @product_family.stub(:product_attributes).and_return(
      [product_attribute_1, product_attribute_2])
  end
  	
  it "renders a form to update product attributes in the product family" do
     render :locals => {:product_family => @product_family}
     response.should have_selector("form", :method => 'post', 
      :action => admin_product_family_path(@product_family)) do |form|
        
        form.should have_selector("input", :name => "_method", :value => "put")
        form.should have_selector("input", :name => "commit", :type => "submit",
          :value => "Remove Checked Attributes")
        form.should have_selector("input", :name => "attrs_to_delete[]", 
          :type => "checkbox", :value => String(@product_family.product_attributes[0].id))
        form.should have_selector("input", :name => "attrs_to_delete[]", 
          :type => "checkbox", :value => String(@product_family.product_attributes[1].id))
          
     end
  end
end