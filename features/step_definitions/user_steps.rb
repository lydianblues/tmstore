Given /^the current user$/ do
  # Refresh the @user variable from the database.
  @user = User.find_by_login(@user.login)
end 

When /^I view the profile page for "([^\"]*)"$/ do |login|
  user = User.find_by_login!(login)
  visit user_url(user)
end

When /^I visit the edit profile page for "([^\"]*)"$/ do |login|
  user = User.find_by_login!(login)
  visit edit_user_url(user)
end

Then /^I should see the show account page for "([^\"]*)"$/ do |login|
  response.should render_template "users/show"
  response.should have_tag("#login", :text => login)
end

Then /^I should see the edit account page for "([^\"]*)"$/ do |login|
  response.should render_template "users/edit"
  response.should have_tag("#user_login[value=" + login + "]")
end

