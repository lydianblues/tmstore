require 'spec_helper'

describe "admin/product_attributes/_edit_attribute.html.erb" do
  
  before(:each) do
    @product_attribute = mock_model(ProductAttribute).as_null_object
    @product_attribute.stub(:name).and_return "Color"
    @product_attribute.stub(:gname).and_return "Food Color"
    # args are: object_name, object, template, options, proc
    @form_builder = FormBuilder.new(
      :product_attribute, @product_attribute, template, nil, nil)
  end
  
  it "should display form contents" do
    render :locals => {:f => @form_builder}
    response.should have_selector("input",
      :name => "product_attribute[name]", :value => "Color")
    response.should have_selector("input",
      :name => "product_attribute[gname]", :value => "Food Color")
  end

end
