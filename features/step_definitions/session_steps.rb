# Register and log in a user.  Set the global variable @user.
# Deprecated.  Use the following step definition.
Given /^I am logged in$/ do
  visit new_user_registration_url
  user = User.make
  fill_in "Login", :with => user.login
  fill_in "Password", :with => user.password
  fill_in "Password confirmation", :with => user.password_confirmation
  fill_in "Email", :with => user.email
  click_button "Sign up"
  within("#flash_notice") do
    page.should have_content("Registration successful.")
  end

  # This enables direct access to the database.
  @user = User.find_by_login(user.login)
end

# Register and log in a user.  Set the global variable @user.
Given /^I am logged in as "([^"]*)"$/ do |login|
  visit new_user_registration_url
  user = User.make(:login => login)
  fill_in "Login", :with => user.login
  fill_in "Password", :with => user.password
  fill_in "Password confirmation", :with => user.password_confirmation
  fill_in "Email", :with => user.email
  click_button "Sign up"
  within("#flash_notice") do
    page.should have_content("Registration successful.")
  end
  
  # This enables direct access to the database.
  @user = User.find_by_login(user.login)
end

# Log out the current user.
Given /^I am not logged in$/ do
  visit root_url
  if page.has_content?("Logout")
    click_link "Logout"
  end
end

Given /^the store has an admin account$/ do
  visit bootstrap_url
  flash.should contain /(Created Site Administrator.)|(Site Administrator already exists.)/
end

# Log in as Admin
Given /^I am logged in as admin$/ do
  visit new_user_session_url
  admin = User.make(:admin)
  fill_in "Login", :with => admin.login
  fill_in "Password", :with => admin.password
  click_button "Login"
  save_and_open_page
  page.should have_content "Login successful."
end

# The user account must have been previously created.
Given /^I am logged in as "(.+)" with password "(.+)"$/ do |login, password|
  visit new_user_session_url
  fill_in "Login", :with => login
  fill_in "Password", :with => password
  click_button "Login"
  flash[:notice].should have_content "Login successful!"
  # response.should contain "You are logged in as #{login}"
  page.should render_template "admin/home/index.html.erb"
  
  @user = User.find_by_login(:first, login)
end

# Register a new user (which automatically does a login).
When /^I register with login "(.+)" and password "(.+)" $/ do |login, password|
  visit new_user_url
  user = User.make!(:login => login, :password => password)
  fill_in "Login", :with => user.login
  fill_in "Password", :with => user.password
  fill_in "Password confirmation", :with => user.password_confirmation
  fill_in "Email", :with => user.email
  click_button "Accept"
  flash[:notice].should have_content "Registration successful."
  page.should render_template "home/show"
  
  @user = User.find_by_login(:first, login)
end
