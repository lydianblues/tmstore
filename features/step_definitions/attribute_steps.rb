Given /^an attribute "([^\"]*)"$/ do |name|
   @product_attribute = ProductAttribute.make(:name => name, :gname => name)
end
