
Given /^the store has a category "([^\"]*)"$/ do |name|
  visit new_admin_category_url
  fill_in "Name", :with => name
  click_button "Create"
  flash.should contain "Category was successfully created."
end

# DMA 
Given /^I add a child category "([^\"]*)" to parent "([^\"]*)"$/ do |cn, pn|
  parent = Category.find_by_name(pn)
  parent.add_subcat(cn)
end

# DMA 
Given /^a category with category path "([^\"]*)"$/ do |catpath|
  # Root category always exists and its path is "/".
  components = catpath.split('/')
  parent = Category.find(Category.root_id)
  components.each do |c|
    next if c.blank?
    parent.add_subcat(c)
    cid = parent.get_child_id_from_name(c)
    parent = Category.find(cid)
  end
  @category = parent # the last category created
end

# DMA
# Use this step with a table like this:
#
#  Given a category tree:
#    | parent | child1 | child2 |
#    | root   | A      | B      |
#    | A      | C      | D      |
#    | C      | E      |        |
#    | D      | F      | G      |
#    | F      | H      | I      |
#
Given /^a category tree:$/ do |table|
  table.rows.each do |r|
    parent = Category.find_by_name(r.shift)
    r.each do |c|
      parent.add_subcat(c)
    end
  end
end

Then /^I should see "([^"]*)" on these category paths:$/ do |selector, table|
  table.raw.each do |r|
    visit products_path
    r.each do |p|
      components = p.split('/')
      components.each do |c|
        next if c.blank?
        click(c)
      end
      page.should have_content(selector)
    end
  end
end

Then /^I should not see "([^"]*)" on these category paths:$/ do |selector, table|
  table.raw.each do |r|
    visit products_path
    r.each do |p|
      components = p.split('/')
      components.each do |c|
        next if c.blank?
        click(c)
      end
      page.should_not have_content(selector)
    end
  end
end

Then /^I should not see "([^"]*)" on these category paths;$/ do |selector, table|
  pending
end



Given /^print message: "([^"]*)"$/ do |msg|
  puts msg
end

When /^I visit the products page for the "([^"]*)" category path$/ do |catpath|
  components = catpath.split('/')
  visit products_path
  components.each do |c|
    next if c.blank?
    click(c)
  end
end

# DMA
Given /^I am on the admin category page for the "([^"]*)" category path$/ do |catpath|
  catid = Category.path_to_id(catpath)
  visit admin_category_path(catid)
end

When /^I visit the admin category page for the "([^"]*)" category path$/ do |catpath|
  components = catpath.split('/')
  visit admin_category_path(Category.root_id)
  components.each do |c|
    next if c.blank?
    within ("#subcategories-box") do
      click(c)
    end
  end
end

Given /^a top-level category "([^\"]*)"$/ do |name|
  cat = Category.make(:name => name, :parent_id => Category.root_id)
  cat.save!
end

When /^I follow category command link "([^"]*)"$/ do |cmd|
  # Nothing to do, since this link is only present toggle visibility
  # of the corresponding command box.  If we used a Javascript driver,
  # then we could verify visibility.
end

Given /^the "([^\"]*)" product family is in the "([^\"]*)" category$/ do |fn, cn|
  cat = Category.find_by_name(cn)
  pf = ProductFamily.find_by_name(fn)
  cat.add_family(pf)
end

Given /^I add the product "([^\"]*)" to the "([^\"]*)" category$/ do |pn, cn|
  cat = Category.find_by_name(cn)
  prod = Product.find_by_name(pn)
  cat.add_product(prod.id)
end

Then /^I should see the "([^\"]*)" category$/ do |cat|

  within("#subcats-content .generic-table tr td a") do
    page.should have_content(cat)
  end

  # response.should have_selector("#subcats-content .generic-table tr") do |tr|
  #  tr.should have_selector("td > a", :content => cat)
  # end
end


Then /^I should see the "([^\"]*)" product family$/ do |family|
  within("#families-content .generic-table tr td a") do
    page.should have_content(family)
  end
#  response.should have_selector("#families-content .generic-table tr") do |tr|
#    tr.should have_selector("td > a", :content => family)
#  end
end

Given /^I remove category "([^\"]*)"$/ do |cn|
  cat = Category.find_by_name(cn)
  cat.destroy
end
