require 'spec_helper'

describe "admin/product_families/_new.html.erb" do
  
  before(:each) do
    @product_family = mock_model(ProductFamily).as_null_object
  end
  
  it "renders a form to assign leaf categories for the product family" do
      
    render :locals => {:product_family => @product_family, :requestor => "New" }
  
    response.should have_selector("form", :method => 'post',
      :action => admin_product_family_path(@product_family) ) do |form|
        form.should have_selector("input", :type => 'hidden', :name => '_method', :value => 'put')
        form.should have_selector("input", :type => 'submit', :name => 'commit', :value => 'Create')
    end
    
  end

end