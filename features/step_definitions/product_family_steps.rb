# DMA
Given /^a product family "([^"]*)" in the "([^"]*)" category$/ do |family, catpath|
  catid = Category.path_to_id(catpath)
  @category = Category.find(catid)
  @product_family = ProductFamily.make(:name => family)
  @product_family.save!
  @category.add_family(@product_family.id) # updates category_families table
end

# DMA
Given /^a product family "([^\"]*)"$/ do |name|
  @product_family = ProductFamily.make(:name => name)
  @product_family.save!
end

Given /^the "([^\"]*)" attribute is in the "([^\"]*)" product family$/ do |aname, pfname|
  pa = ProductAttribute.find_by_name(aname)
  pf = ProductFamily.find_by_name(pfname)
  pf.add_attribute(pa)
end
