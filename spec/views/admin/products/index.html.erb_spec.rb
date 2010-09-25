require 'spec_helper'

describe "admin/products/index.html.erb" do
  
  before(:each) do
    product_search = mock_model(ProductSearch).as_null_object
    product_search.stub(:sort_by).and_return("1")
    assigns[:product_search] = product_search
    assigns[:products] = []
    assigns[:previous_url] = "/home/admin"
  end

  it "renders the 'product_search' partial" do
   
    template.should_receive(:render).with(
      :partial => 'admin/products/product_search', :object => assigns[:product_search])
    render :layout => true
  end
 
 it "renders the 'products_table' partial" do
   template.should_receive(:render).with(
      :partial => 'admin/products/products_table',
      :locals => {:products => assigns[:products]})
    render :layout => true
  end

end
