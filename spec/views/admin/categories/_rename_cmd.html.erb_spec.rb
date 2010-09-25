require 'spec_helper'

describe "admin/categories/_rename_cmd.html.erb" do
  
  before(:each) do
    @category = mock_model(Category).as_null_object 
  end
  
  it "displays the 'Rename Category' header" do
    render :locals => {:category => @category}
    response.should have_selector "div.cmd-hdr", :content => "Rename Category"
  end
    	
  it "should display the 'Rename Category' form" do
    render :locals => {:category => @category}
    response.should have_selector "form.ajax-form",
       {:method => "post", :action => admin_category_path(@category) }
    response.should have_selector "input",
      {:name => "_method", :type => "hidden", :value => "put"}
    response.should have_selector "input",
      {:type => "hidden", :name => "command", :value => "rename"}
    response.should have_selector "input",
      {:type => "text", :name => "name"}
    response.should have_selector "input",
      {:name => "commit", :type => "submit", :value => "Rename"}
 
  end
  
end