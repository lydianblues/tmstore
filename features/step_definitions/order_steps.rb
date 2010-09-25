Given /^the current order$/ do
  Order.all.count.should == 1
  @order = Order.first
end

Given /^I have an empty cart$/ do
  # nothing to do
  true
end

Given /^the store contains purchased orders for "([^"]*)"$/ do |login|


end


Given /^my order has at least one product$/ do
  visit products_url
  find(".product-link").click
  click_button "Add to Cart"
  find("#flash_notice").text.should == "Updated quantities in cart."
end

Given /^my order is missing a "([^\"]*)" address$/ do |addr_type|
  # Nothing to do.  The order won't have a billing address unless we add one.
end

Given /^I have created a valid order$/ do
  Given "my order has at least one product"
  And "my order has a \"billing\" address"
  And "my order has a \"shipping\" address"
end
