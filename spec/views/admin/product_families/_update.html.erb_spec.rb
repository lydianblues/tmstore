require 'spec_helper'

describe "admin/product_families/_update.html.erb" do
  
  before(:each) do
    @product_family = mock_model(ProductFamily, 
      :name => "Cameras", :description => "Camera Description").as_null_object
  end
  
  it "displays the 'Product Family' update form" do
    render :locals => {:product_family => @product_family}
    response.should have_selector "form", :action => admin_product_family_path(@product_family),
      :method => "post"
    response.should have_selector "input", :name => "_method", :type => "hidden", :value => "put"
    response.should have_selector "input", :name => "product_family[name]",
      :type => "text", "value" => "Cameras"
    response.should have_selector "textarea", :name => "product_family[description]",
     :content => "Camera Description"
    response.should have_selector "input", :name => "commit", :type => "submit",
      :value => "Update Name/Description"
  end
end

