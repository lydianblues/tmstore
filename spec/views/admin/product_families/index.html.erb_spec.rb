require 'spec_helper'

describe "admin/product_families/index.html.erb" do
  
  before(:each) do
    assigns[:previous_url] = "/home/admin"
  end
  
  it "displays the 'Manage Product Families' banner" do
    assigns[:leaf_categories] = double(Array).as_null_object
    assigns[:product_families] = double(Array).as_null_object
    render :layout => true
    response.should contain("Manage Product Families")
  end
  
  it "renders the admin/product_families/summary partial" do
    assigns[:product_families] = double(Array).as_null_object
    template.should_receive(:render).with(
      :partial => "summary", :object => assigns[:product_families] )
    render :layout => true
  end
end