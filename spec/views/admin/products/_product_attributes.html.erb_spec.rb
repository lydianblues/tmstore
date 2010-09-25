require 'spec_helper'

describe "admin/products/_product_attributes.html.erb" do

  before(:each) do
    @product_attributes = []
    @product = mock_model(Product).as_null_object
  end
  		
  it "should render a 'Update Family Attributes' button" do
    render :locals => {:product => @product,
      :product_attributes => @product_attributes}
    response.should have_selector("input", :name => "commit",
      :type => "submit", :value => "Update Family Attributes")
  end

end
