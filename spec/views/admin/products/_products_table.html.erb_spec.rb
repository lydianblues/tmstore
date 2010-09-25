require 'spec_helper'

describe "admin/products/_products_table.html.erb" do

  before(:each) do
    @products = mock_model(WillPaginate::Collection).as_null_object
  end
    
  context "when no products are found" do
    it "should render a 'no match' message" do
      render :locals => {:products => @products}
      response.should contain("There are no matching products.")
    end
  end
  
  context "when products are found" do
    it "should list the products that are found" do
      product = mock_model(Product).as_null_object
      product.stub(:name).and_return("Cheese Balls")
      @products = [product].paginate
      render :locals => {:products => @products}
      response.should have_selector("td", :content => "Cheese Balls")
  	end
  end
end
