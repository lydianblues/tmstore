require 'spec_helper'

describe "admin/categories/_create_cmd.html.erb" do
  
  before(:each) do
    @category = mock_model(Category).as_null_object 
  end
  
  it "displays the 'Create a Subcategory' header" do
    render :locals => {:parent => @category}
    response.should have_selector "div.cmd-hdr", :content => "Create a Subcategory"
  end
  
  it "should display the 'Create a Subcategory' form" do
    render :locals => {:parent => @category}
    response.should have_selector "input",
      {:name => "commit", :type => "submit", :value => "Create"}
    response.should have_selector "form.ajax-form",
      {:method => "post", :action => admin_categories_path }
    response.should have_selector "input#category_parent_id",
      {:name => "category[parent_id]", :type => "hidden",
       :value => String(@category.id)}
  end
  
end