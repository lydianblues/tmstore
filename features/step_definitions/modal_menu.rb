Then /^I should see the filter menu$/ do
  page.should have_content("#filter-menu")
  page.should_not have_content("#filter-menu.hidden")
end

Then /^I should not see the filter menu$/ do
  page.should have_content("#filter-menu.hidden")
end

Then /^I should see the category menu$/ do
  page.should have_content("#category-menu")
  page.should_not have_content("#category-menu.hidden")
end

Then /^I should not see the category menu$/ do
  save_and_open_page
  page.should have_content("#category-menu.hidden")
end
