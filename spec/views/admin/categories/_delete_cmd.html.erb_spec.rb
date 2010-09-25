require 'spec_helper'

describe "admin/categories/_delete_cmd.html.erb" do
  
  before(:each) do
    @category = mock_model(Category).as_null_object 
  end
  
  it "displays the 'Delete Category' header" do
    render :locals => {:category => @category}
    response.should have_selector "div.cmd-hdr", :content => "Delete Category"
  end
  
  it "should display the 'Delete Category' form" do
    render :locals => {:category => @category}
    response.should have_selector "input",
      {:name => "commit", :type => "submit", :value => "Delete"}
    response.should have_selector "input",
      {:name => "_method", :type => "hidden", :value => "delete"}
    response.should have_selector "form.ajax-form",
      {:method => "post", :action => admin_category_path(@category) }
  end
  
end