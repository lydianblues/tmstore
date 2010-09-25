require 'spec_helper'

describe "admin/categories/show.html.erb" do
  
  before(:each) do
    assign(:category, mock_model(Category).as_null_object)
    assign(:subcats, [])
    assign(:previous_url, "/home/admin")
    assign(:families, [])
    assign(:attributes, [])
  end
  
  it "displays the 'Manage Product Families' banner" do
    render #:layout => true
    find_method(:render)
    view.should contain("Manage Categories")
  end
  
  it "renders the create category command box" do
	  view.should_receive(:render).with(
	    :partial => "create_cmd", :locals => {:parent => assigns[:category]})
	  render :layout => true
	end
	
	it "renders the delete category command box" do
	  view.should_receive(:render).with(
	    :partial => "delete_cmd", :locals => {:category => assigns[:category]})
	  render :layout => true
	end
	
	it "renders the rename category command box" do
	  view.should_receive(:render).with(
	    :partial => "rename_cmd", :locals => {:category => assigns[:category]})
	  render :layout => true
	end
	
	it "renders the reparent category command box" do
	  view.should_receive(:render).with(
	    :partial => "reparent_cmd", :locals => {:category => assigns[:category]})
	  render :layout => true
	end
	
	it "renders the add family to category command box" do
	  view.should_receive(:render).with(
	    :partial => "add_family_cmd", :locals => {:category => assigns[:category]})
	  render :layout => true
	end
	
	it "renders the subcategories panel" do
	  view.should_receive(:render).with(
	    :partial => "subcategories", :object => assigns[:subcats],
	    :locals => {:category => assigns[:category]})
	  render :layout => true
          puts rendered
	  # rendered.should have_selector "div.panel-header", :content => "Subcategories"
	end
	
	it "renders the product families panel" do
	  view.should_receive(:render).with(
	    :partial => "families", :object => assigns[:families],
	    :locals => {:category => assigns[:category]})
	  render :layout => true
	  rendered.should have_selector "div.panel-header", :content => "Product Families"
	end
	
	it "renders the product attributes panel" do
	  view.should_receive(:render).with(
	    :partial => "attributes", :object => assigns[:attributes])
	  render :layout => true
	  rendered.should have_selector "div.panel-header", :content => "Product Attributes"
	end

end
