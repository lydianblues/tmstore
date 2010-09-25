require 'spec_helper'

describe "admin/products/_general_attrs.html.erb" do
  before (:each) do
    @product = mock_model(Product).as_null_object
  end
  context "when creating a product family" do
    context "when a product family has not been selected" do
      it "render a prompt to select a product family" do
        @product.stub(:product_family).and_return nil
        render :locals => {:requestor => "New", :product => @product}
        response.should contain(
          "Choose a product family from the column to the left.")
      end
    end
    context "when a product family has been selected" do
      it "should render a prompt to submit the form" do
        product_family = mock_model(ProductFamily).as_null_object
        @product.stub(:product_family).and_return(product_family)
        render :locals => {:requestor => "New", :product => @product}
        response.should have_selector("input",
          :type => "submit", :value => "Create")
      end
    end
  end

  context "editing exiting product family" do
    it "should display an 'Update' button" do
       product_family = mock_model(ProductFamily).as_null_object
       @product.stub(:product_family).and_return(product_family)
       render :locals => {:requestor => "Edit", :product => @product}
       response.should have_selector("input",
         :type => "submit", :value => "Update")
    end
  end
end
