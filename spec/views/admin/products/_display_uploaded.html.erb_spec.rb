require 'spec_helper.rb'

describe "admin/products/_display_uploaded.html.erb" do
  
  before(:each) do
    @product = mock_model(Product)
    @product.stub(:photos).and_return []
  end

  it "renders a form to upload photos" do
    render :locals => {:product => @product}
    response.should have_selector("form", :method => 'post',
      :action => photos_path)
  end

end
