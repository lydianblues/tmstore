require 'spec_helper'

describe "admin/products/_visibility_paths.html.erb" do

  before(:each) do
    @product = mock_model(Product).as_null_object
    @candidate_paths = []
  end

  it "renders the 'visibility_paths' partial" do
    render :locals => {:product => @product,
                      :candidate_paths => @candidate_paths}
    response.should have_selector("input",
      :type => "submit", :value => "Update Visibility Paths")
  end

end
