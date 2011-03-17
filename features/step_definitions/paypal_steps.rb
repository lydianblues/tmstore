Then /^I fill in "([^"]*)" with the paypal buyer username$/ do |field|
  fill_in(field, :with => APP_CONFIG[:paypal_buyer_username])
end

Then /^I fill in "([^"]*)" with the paypal buyer password$/ do |field|
  fill_in(field, :with => APP_CONFIG[:paypal_buyer_password])
end

Given /^I fill in the fields with a valid PayPal Credit Card$/ do
  fill_in("First Name", :with => "Test")
  fill_in("Last Name", :with => "User")
  fill_in("Credit Card Number", :with => "4592812235739194")
  fill_in("card_exp_month", :with => "04")
  fill_in("card_exp_year", :with => "15")
  fill_in("CSC", :with => "077")
  fill_in("Billing Address Line 1", :with => "1 Main St.")
  fill_in("City", :with => "San Jose")
  select("California", :from => "address_state")
  select("United States", :from => "address_country")
  fill_in("Postal Code", :with => "95131")
end

When /^I nap for a while$/ do
  sleep 10
end  
