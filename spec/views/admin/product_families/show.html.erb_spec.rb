require 'spec_helper'

describe "admin/product_families/show.html.erb" do
  
  before(:each) do
    product_family = mock_model(ProductFamily).as_null_object
    product_attributes = [mock_model(ProductAttribute).as_null_object].paginate
    product_family.stub(:product_attributes).and_return(product_attributes)
    assigns[:product_family] = product_family
    assigns[:product_attributes] = product_attributes
    assigns[:operations] = %w[edit]
    assigns[:previous_url] = "/home/admin"
  end
  
  it "displays the 'View Product Family' banner" do
    assigns[:product_family] = mock_model(ProductFamily).as_null_object
    render :layout => true
    response.should contain("View Product Family")
  end
  
   it "renders the 'admin/product_attributes/attribute' partial" do
     template.should_receive(:render).with(
      :partial => 'admin/product_attributes/attribute',
      :collection => assigns[:product_attributes],
      :locals => {:product_family => assigns[:product_family],
                  :operations => assigns[:operations]} )
     render :layout => true
  end
end