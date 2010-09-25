require 'spec_helper'

describe "admin/product_attributes/index.html.erb" do
  
  before(:each) do
    assigns[:requestor] = mock_model(ProductFamily)
    assigns[:attribute_search] = double(AttributeSearch).as_null_object
    assigns[:product_families] = []
    assigns[:product_attributes] = [].paginate
  end
  
  it "displays the Product Attributes banner" do
  
    # Must use :layout => true, otherwise all the content saved away
    # using content_for (i.e. the whole page) will not be rendered.
    render :layout => true
    
    response.should contain("Product Attributes")
  end
  
  it "should paginate the attribute list" do
    
    data = (1..5).map { |i| double(ProductAttribute, :id => i).as_null_object }
    paginated_data = data.paginate(:page => 2, :per_page => 4)
    assigns[:product_attributes] = paginated_data
    
    render :layout => true
    
    # Expect "< Previous 1 2 Next >", with 2 the current page,
    # and "Next" disabled.
    
    response.should have_selector("div.pagination > a",
      :href => paginate_admin_product_attributes_path(:page => "1"),
      :class => "prev_page")
      
    response.should have_selector("div.pagination > span", :class => "current") do |span|
      span.should contain("2")
    end
  end
  
  it "renders the find attributes template" do
    template.should_receive(:render).with(
      :partial => 'find_attributes',
      :locals => {:url => search_admin_product_attributes_path,
                  :attribute_search => assigns[:attribute_search],
                  :operations => %w[edit delete]})
    render :layout => true
  end
  
  it "should display all product families in the sidebar" do
    pf = mock_model(ProductFamily, :id => 10001).as_null_object
    assigns[:product_families] = [pf]
    render :layout => true
    response.should have_selector("div#families-list a",
      :href => admin_product_family_path(pf))
  end
    
end