# DMA
Given /^a product family "([^"]*)" in the "([^"]*)" category$/ do |family, catpath|
  catid = Category.path_to_id(catpath)
  cat = Category.find(catid)
  if cat.leaf?
    pf = ProductFamily.make(:name => family)
    pf.save!
    cat.add_family(pf.id) # updates category_families table
  end
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
