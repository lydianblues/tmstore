require 'spec_helper'

describe "admin/products/_upload_photos.html.erb" do

  before(:each) do
    @photo = mock_model(Photo).as_null_object
    @product = mock_model(Product).as_null_object
  end
  
  it "should render a form with an 'Upload Photo' button" do
    render :locals => {:photo => @photo, :product => @product}
    response.should have_selector("input",
      :type => "submit", :value => "Upload Photo")
  end

end
