Given /^I have no products$/ do
  Product.delete_all
end

Given /^a product "([^\"]*)" in the "([^\"]*)" product family$/ do |pn, fn|
  pf = ProductFamily.find_by_name(fn)
  Product.make(:name => pn, :product_family => pf).save!
end

When /^I visit the products page for category "([^\"]*)"$/ do |cn|
  cat = Category.find_by_name(cn)
  visit products_path(:catid => cat.id)
end

Then /^I should have ([0-9]+) products?$/ do |count|
  Product.count.should == count.to_i
end

Then /^I should see ([0-9]+) products? in the table$/ do |count|
  # We have to add 1 for the header row.
  page.all(".generic-table tr").length.should == Integer(count) + 1
end

Then /^the store should have one more product$/ do
  pending # express the regexp above with the code you wish you had
end

# DMA
Given /^the store has at least one product$/ do
  pf = ProductFamily.make
  pf.save!
  product = Product.make(:product_family => pf).save!
end

# Need to be logged in as admin.  The product family should already exist.
When /^I create a product "([^\"]*)" in the "([^\"]*)" product family$/ do |name, family|
  visit new_admin_product_path
  page.should have_content("Choose a product family from the column to the left.")
  click_link family

  # Should verify that the selected product family is correct, as well as this...
  page.should_not have_content("Choose a product family")

  product = Product.make(:name => name)
  fill_in "Name", :with => product.name
  fill_in "Price", :with => product.price
  fill_in "Description", :with => product.description
  fill_in "Length", :with => product.shipping_length
  fill_in "Width", :with => product.shipping_width
  fill_in "Height", :with => product.shipping_height
  fill_in "Weight", :with => product.shipping_weight

  click_button "Create"
  page.find("#flash_notice").text.should == "Product was successfully created."
end

When /^I create a product "([^"]*)" in the "([^"]*)" product family with visibility path "([^"]*)"$/ do |product, family, path|
  visit new_admin_product_path
   page.should have_content("Choose a product family from the column to the left.")
  click_link family
  page.should_not have_content("Choose a product family")
  product = Product.make(:name => product)
  fill_in "Name", :with => product.name
  fill_in "Price", :with => product.price
  fill_in "Description", :with => product.description
  fill_in "Length", :with => product.shipping_length
  fill_in "Width", :with => product.shipping_width
  fill_in "Height", :with => product.shipping_height
  fill_in "Weight", :with => product.shipping_weight
  click_button "Create"
  page.find("#flash_notice").text.should == "Product was successfully created."
  check(path)
  click_button("Update Visibility Paths")
end

Given /^the following products$/ do |table|
  table.hashes.each do |hash|
    hash['product_family'] = ProductFamily.find_by_name(hash[:product_family])
    Product.make!(hash)
  end
end

Then /^I should see "([^\"]*)" in the "([^\"]*)" product family$/ do |name, family|
  table = page.find(".generic-table")
  table.should have_row_for_product_in_family(name, family)
end




