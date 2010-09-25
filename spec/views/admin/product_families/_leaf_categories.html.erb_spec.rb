require 'spec_helper'

describe "admin/product_families/_leaf_categories.html.erb" do
  
  before(:each) do
    @leaf_categories = []
    @product_family = mock_model(ProductFamily).as_null_object
  end
  
  it "renders a form to assign leaf categories for the product family" do
    # Should really have :object => @leaf_categories, but that doesn't seem
    # to work.
    render :locals => {:product_family => @product_family,
      :leaf_categories => @leaf_categories}
    
    #
    # 'get' is used, because we're really getting an updated form that
    # will subsequently be submitted.
    #
    response.should have_selector("form", :method => 'get') do |form|
      response.should have_selector("input", :name => 'commit', :value => 'Submit Selected')
      response.should have_selector("input", :name => 'commit', :value => 'Clear All')
    end
         
  end
end