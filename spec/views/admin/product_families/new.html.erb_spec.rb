require 'spec_helper'

describe "admin/product_families/new.html.erb" do
  
  before (:each) do
    assigns[:product_family] = mock_model(ProductFamily).as_null_object
    assigns[:leaf_categories] = double(Array).as_null_object
    assigns[:previous_url] = "/home/admin"
  end
  
  it "displays the 'Create a new Product Family' banner" do
    render :layout => true
    response.should contain("Create a new Product Family")
  end

  it "renders the 'leaf_categories' partial" do
		template.should_receive(:render).with(
      :partial => "leaf_categories",
      :object => assigns[:leaf_categories],
      :locals => {:product_family => assigns[:product_family]})
    render :layout => true
  end
  
  it "renders the 'new' partial" do	
		template.should_receive(:render).with(
      :partial => "new",
      :locals => {:product_family => assigns[:product_family], :requestor => "New" })
    render :layout => true
  end
  
end

