require 'spec_helper'

describe "admin/categories/_add_family_cmd.html.erb" do
  
  before(:each) do
    @category = mock_model(Category).as_null_object 
  end
  
  it "displays the 'Add a Product Family' header" do
    render :locals => {:category => @category}
    response.should have_selector "div.cmd-hdr", 
      :content => "Add a Product Family"
  end
  
  it "should display the 'Add a Product Family' form" do
    render :locals => {:category => @category}
    response.should have_selector "form.ajax-form",
       {:method => "post", :action => admin_category_path(@category) }
    response.should have_selector "input",
      {:name => "_method", :type => "hidden", :value => "put"}
    response.should have_selector "input",
      {:type => "hidden", :name => "command", :value => "add_family"}
    
    response.should have_selector "input",
      {:type => "text", :name => "family[id]"}
      response.should have_selector "input",
        {:type => "text", :name => "family[name]"}
    
    response.should have_selector "input",
      {:name => "commit", :type => "submit", :value => "Add"}
 
  end
  
end
