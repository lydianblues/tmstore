require 'spec_helper'

describe "admin/product_families/_summary.html.erb" do
  
  before(:each) do
   product_family = mock_model(ProductFamily, :name => "Cameras").as_null_object
   product_family.stub(:products).and_return []
   product_family.stub(:categories).and_return []
   product_family.stub(:product_attributes).and_return []
   @summary = [product_family]
  end
  
  context "when summaries array is not empty" do
    it "displays product families summary table" do
       render :locals => {:summary => @summary}
       response.should have_selector "table#families-content"
       response.should have_selector "td a",
        :href => admin_product_family_path(@summary[0]),
        :content => "Cameras"
    end
  end
  
  context "when summaries array is empty" do
    it "should show a message that there are no product families" do
      render :locals => {:summary => []}
      response.should contain("There are no product families.")
    end
  end
end