require 'spec_helper'

describe "admin/products/new.html.erb" do
  
  before(:each) do
    assigns[:product] = mock_model(Product).as_null_object
    assigns[:product_families] = []
    product_family = mock_model(ProductFamily).as_null_object
    product_attributes = [mock_model(ProductAttribute).as_null_object].paginate
    product_family.stub(:product_attributes).and_return(product_attributes)
    assigns[:product_family] = product_family
    assigns[:product_attributes] = product_attributes
    assigns[:previous_url] = "/home/admin"
  end

  it "renders the 'general_attrs' partial" do
     template.should_receive(:render).with(
       :partial => 'general_attrs', 
       :locals => {:requestor => 'New', :product => assigns[:product],
     			        :product_family => assigns[:product_family]})
     render :layout => true   
   end
  
    it "renders the 'admin/product_attributes/attribute' partial" do
      template.should_receive(:render).with(
       :partial => 'admin/product_attributes/attribute',
       :collection => assigns[:product_attributes],
       :locals => {:operations => []} )
      render :layout => true
   end

end
