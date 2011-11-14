When /enter a valid "(.+)" address/ do |addr_type|
  address = Address.make
  fill_in "address[first_name]", :with => address.first_name
  fill_in "address[last_name]", :with => address.last_name
  fill_in "address[street_1]", :with => address.street_1
  fill_in "address[street_2]", :with => address.street_2 unless address.street_2.blank?
  fill_in "address[city]", :with => address.city
  fill_in "address[email]", :with => address.email
  fill_in "address[postal_code]", :with => address.postal_code
  fill_in "address[region]", :with => address.region unless address.region.blank?
  select address.country, :from => "address_country"
  select address.province, :from => "address_province" unless address.province.blank?
  select address.state, :from => "address_state" unless address.state.blank?
end

Then /^the billing address is associated with my order$/ do
  step "the current order"
  Address.billing.all.should include(@order.billing_address)
end

Then /^the billing address is associated with my account$/ do
  step "the current user"
  Address.billing.all.should include(@user.billing_address)
end

Then /^the shipping address is associated with my order$/ do
  step "the current order"
  Address.shipping.all.should include(@order.shipping_address)
end

Then /the shipping address is associated with my account$/ do
  step "the current user"
  Address.shipping.all.should include(@user.shipping_address)
end

Given /^my order has a "(billing|shipping)" address$/ do |addr_type|
  if addr_type == 'billing'
    visit new_address_billing_url
    page.should have_content("Enter Billing Information")
  end
  if addr_type == 'shipping'
    visit new_address_shipping_url
    page.should have_content("Enter Shipping Information")
  end
  address = Address.make!
  fill_in "First Name", :with => address.first_name
  fill_in "Last Name", :with => address.last_name
  fill_in "Email", :with => address.email
  fill_in "Telephone Number", :with => address.phone_number
  fill_in "Street", :with => address.street_1
  fill_in "City", :with => address.city
  fill_in "ZIP or Postal Code", :with => address.postal_code
  select address.country, :from => "address_country"
  select address.state, :from => "address_state" unless address.state.blank?
  select address.province, :from => "address_province" unless address.province.blank?
  fill_in "Region", :with => address.region unless address.region.blank?
  if addr_type == 'billing'
    click_button "Proceed to Shipping"
    page.should have_content "Enter Shipping Information"
  end
  if addr_type == 'shipping'
    click_button "Choose Shipping Method"
    page.should have_content("Choose a Shipping Carrier and Method")
  end
end

Then /^my order has a shipping address that is the same as the billing address$/ do
  step "the current order"
  billing = @order.billing_address
  shipping = @order.shipping_address
  Address.shipping.find(:all).should include(shipping)
  Address.billing.find(:all).should include(billing)
  billing.first_name.should == shipping.first_name
end

Then /^my account has a shipping address that is the same as the billing address$/ do
  step "the current user"
  billing = @user.billing_address
  shipping = @user.shipping_address
  Address.shipping.find(:all).should include(shipping)
  Address.billing.find(:all).should include(billing)
  billing.first_name.should == shipping.first_name
end

Given /^I have previously created a billing address$/ do
  step "the current user"
  address = Address.make!(:address_type => 'billing')
  @user.billing_address = address
  @user.save!
  puts address.to_yaml
end

Given /^I have previously created a shipping address$/ do
  step "the current user"
  address = Address.make!(:address_type => 'shipping')
  @user.shipping_address = address
  address.should_not be_nil
  @user.save!
end

Then /^the billing address form should be filled in from my profile$/ do
  step "the current user"
  address = @user.billing_address
  address.should_not be_nil
  get new_address_billing_path
  page.should contain_address(address)
end

Then /^the shipping address form should be filled in from my profile$/ do
  step "the current user"
  address = @user.shipping_address
  address.should_not be_nil
  get new_address_shipping_path
  response.should render_template "address/shipping/new"
  page.should contain_address(address) # custom matcher
end

When /^I check Shipping Address is the same as Billing Address$/ do
  check("same_as_billing")
end

When /^I do an invalid change to my "(billing|shipping)" address$/ do |addr_type|
  fill_in "First Name", :with => ""
end





