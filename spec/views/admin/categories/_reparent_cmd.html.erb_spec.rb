require 'spec_helper'

describe "admin/categories/_reparent_cmd.html.erb" do
  
  before(:each) do
    @category = mock_model(Category).as_null_object 
  end
  
  it "displays the 'Reparent Category' header" do
    render :locals => {:category => @category}
    response.should have_selector "div.cmd-hdr", :content => "Reparent Category"
  end
  
  it "should display the 'Reparent Category' form" do
    render :locals => {:category => @category}
    response.should have_selector "form.ajax-form",
       {:method => "post", :action => admin_category_path(@category) }
    response.should have_selector "input",
      {:name => "_method", :type => "hidden", :value => "put"}
    response.should have_selector "input",
      {:type => "hidden", :name => "command", :value => "reparent"}
    response.should have_selector "input",
      {:type => "text", :name => "new_parent_id"}
      response.should have_selector "input",
        {:type => "text", :name => "new_parent_path"}
    response.should have_selector "input",
      {:name => "commit", :type => "submit", :value => "Reparent"}
 
  end
  
end

