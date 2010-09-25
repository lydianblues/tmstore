require 'spec_helper'

describe "admin/product_families/edit.html.erb" do
  
  before(:each) do
    product_family = mock_model(ProductFamily).as_null_object
    product_attributes = [mock_model(ProductAttribute).as_null_object].paginate
    product_family.stub(:product_attributes).and_return(product_attributes)
    
    assigns[:product_family] = product_family
    assigns[:product_attributes] = product_attributes
   
    assigns[:attribute_search] = mock_model(AttributeSearch).as_null_object
    assigns[:product_families] = double(Array).as_null_object
    assigns[:url] = search_admin_product_families_path(:pfid => product_family.id)
    assigns[:operations] = %w[edit add remove]
    assigns[:previous_url] = "/home/admin"
  end
  
  it "displays the 'Edit Product Family' banner" do
     render :layout => true
     response.should contain("Edit Product Family")
  end
  	
  it "renders the 'family_attributes' partial" do
    template.should_receive(:render).with(
      :partial => 'family_attributes',
      :locals => {:product_family => assigns[:product_family]} )
    render :layout => true
  end
  
  it "renders the 'update' partial" do
    template.should_receive(:render).with(
      :partial => 'update',
      :locals => { :product_family => assigns[:product_family] })
    render :layout => true
  end
  
  it "renders the 'admin/product_attributes/find_attributes' partial" do
     template.should_receive(:render).with(
       :partial => 'admin/product_attributes/find_attributes', 
       :locals => {:url => assigns[:url],
                   :attribute_search => assigns[:attribute_search]} )
     render :layout => true
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