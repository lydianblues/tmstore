Feature: Check out with PayPal Express
  In order to pay for my order
  As a user
  I want to check out

  Background: Developer login to PayPal
    When I go to the PayPal developer website
    And I fill in "Email Address" with "mbs@thirdmode.com"
    And I fill in "Password" with "zalogu53"
    And I check "cb_auto_login"
    And I press "Log In"
    Then I should see "Log Out"

  @selenium
  Scenario: check out with PayPal Express
    Given I am on the home page
    And I follow "Load Your Shopping Cart"
    And I follow "View Your Shopping Cart"
    When I press "Check out with PayPal Express"
    Then show me the page
    Then I should see "Create a PayPal Account or Log In"
    And I fill in "login_email" with the paypal buyer username
    And I fill in "login_password" with the paypal buyer password
    And I press "Log In"
    Then I should see "Review your information"
    When I press "Continue"
    Then I should see "PayPal Express Confirmation Page"
    When I press "Complete Purchase"
    Then I should see "PayPal Express Payment succeeded."
