require 'spec_helper'

describe "admin/product_attributes/_find_attributes.html.erb" do
  
  before(:each) do
    @as = double(AttributeSearch).as_null_object
  end

  context "When the form is rendered" do
    it "contains a submit field" do 
      render :locals => {:attribute_search => @as,
        :requestor => nil, :url => ""}
      response.should have_selector("input", :type => "submit",
        :value => "Search for Attributes")
    end
  end
  
end
