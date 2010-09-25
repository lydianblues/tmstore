require 'spec_helper'

describe "admin/products/_product_search.html.erb" do
  
  before(:each) do
    @product_search = mock_model(ProductSearch).as_null_object
    @product_search.stub(:sort_by).and_return("1")
    
  end

  it "should render a 'Search' button" do
    render :locals => {:product_search => @product_search}
    response.should have_selector("input", :name => "commit",
      :type => "submit", :value => "Search")
  end

end
