require 'spec_helper'

describe "admin/products/edit.html.erb" do
  
  before(:each) do
    assigns[:product] = mock_model(Product).as_null_object
    assigns[:product_family] = mock_model(ProductFamily).as_null_object
    assigns[:product_attributes] = []
    assigns[:candidate_paths] = []
    assigns[:previous_url] = "/home/admin"
  end
    
  it "renders the 'general_attrs' partial" do
    template.should_receive(:render).with(
      :partial => 'general_attrs',
      :locals => {:requestor => 'Edit', :product => assigns[:product],
    			        :product_family => assigns[:product_family]})
    render :layout => true   
  end
  
  it "renders the 'product_attributes' partial" do
    template.should_receive(:render).with(
      :partial => 'product_attributes',
      :object => assigns[:product_attributes],
    	:locals => {:product => assigns[:product]})
    render :layout => true
  end
  
  it "renders the 'upload_photos' partial" do
    template.should_receive(:render).with(
      :partial => 'upload_photos',
      :locals => {:product => assigns[:product]})
    render :layout => true
  end
  
  
  it "renders the 'display_uploaded' partial" do
    template.should_receive(:render).with(
      :partial => 'display_uploaded',
      :locals => {:product => assigns[:product]})
    render :layout => true
  end
  
  it "renders the 'visibility_paths' partial" do
    template.should_receive(:render).with(
      :partial => 'visibility_paths',
      :locals => {:product => assigns[:product],
                  :candidate_paths => assigns[:candidate_paths]})
    render :layout => true
  end

end
