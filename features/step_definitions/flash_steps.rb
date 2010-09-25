Then /^the flash message should be "([^\"]*)"$/ do |msg|
  response.should have_selector("#flash_notice")
end
