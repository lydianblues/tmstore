Feature: Manage Addresses
  In order to process my purchase
  As a user
  I want to record and edit billing and shipping addresses for my order

  Background: 
    Given the store is initialized

  Scenario: Save billing address when logged in
    Given I am logged in
    And I am on the page to edit my billing address
    And I enter a valid "billing" address
    And I press "Create Address"
    Then I should see "Your billing address has been saved."

  Scenario: Save shipping address when logged in
    Given I am logged in
    And I am on the page to edit my shipping address
    And I enter a valid "shipping" address
    And I press "Create Address"
    Then I should see "Your shipping address has been saved."

  Scenario: Save Billing Address When not logged in
    Given I am not logged in
    And I am on the page to enter my billing address
    When I enter a valid "billing" address
    And I press "Create Address"
    Then the billing address is associated with my order
    And I should see "Your billing address has been saved."
      		
  Scenario: Save Shipping Address When not logged in
    Given I am not logged in
    And I am on the page to enter my shipping address
    When I enter a valid "shipping" address
    And I press "Create Address"
    Then the shipping address is associated with my order
    And I should see "Your shipping address has been saved."
      		
  Scenario: Save Billing Address When logged in
    Given I am logged in
    And I am on the page to enter my billing address
    When I enter a valid "billing" address
    And I press "Create Address"
    Then the billing address is associated with my order
    And the billing address is associated with my account
    And I should see "Your billing address has been saved."

  Scenario: Save Shipping Address When logged in
    Given I am logged in
    And I am on the page to enter my shipping address
    When I enter a valid "shipping" address
    And I press "Create Address"
    Then the shipping address is associated with my order
    And the shipping address is associated with my account
    And I should see "Your shipping address has been saved."
      
  Scenario: Billing Address is filled in from my Profile When logged in
    Given I am logged in
    And I have previously created a billing address
    When I go to the page to edit my billing address
    Then the billing address form should be filled in from my profile
      
  Scenario: Shipping Address is filled in from my Profile When logged in
    Given I am logged in
    And I have previously created a shipping address
    When I go to the page to enter my shipping address
    Then the shipping address form should be filled in from my profile
      
  Scenario: Shipping Address is copied from Billing Address when logged in.
    Given I am logged in
    And I am on the page to enter my billing address
    When I enter a valid "billing" address
    And I check Shipping Address is the same as Billing Address
    And I press "Proceed to Shipping"
    Then the billing address is associated with my order
    And the billing address is associated with my account
    And my order has a shipping address that is the same as the billing address
    And my account has a shipping address that is the same as the billing address
    And I should see "Choose a Shipping Carrier and Method"
      	
  Scenario: Shipping Address is copied from Billing Address when not logged in.
    Given I am not logged in
    And I am on the page to enter my billing address
    When I enter a valid "billing" address
    And I check Shipping Address is the same as Billing Address
    And I press "Proceed to Shipping"
    Then the billing address is associated with my order
    And my order has a shipping address that is the same as the billing address
    And I should see "Choose a Shipping Carrier and Method"

  Scenario: Fail when creating a new order with no billing address
    Given my order has at least one product
    And my order is missing a "billing" address
    When I go to the order review page
    Then I should see "Please fill in billing and shipping addresses as you checkout."
    And I should be on the shopping cart page

  Scenario: Fail when creating a new order with no shipping address
    Given my order has at least one product
    And my order is missing a "shipping" address
    When I go to the order review page
    Then I should see "Please fill in billing and shipping addresses as you checkout."
    And I should be on the shopping cart page
      
  Scenario: Fail when creating a new order with an empty cart
    Given I have an empty cart
    And my order has a "billing" address
    And my order has a "shipping" address
    When I go to the order review page
    Then I should see "Please add items to your cart before you checkout."
    And I should be on the shopping cart page
      
  Scenario: Create a valid order
    Given my order has at least one product
    And my order has a "billing" address
    And my order has a "shipping" address
    When I go to the order review page
    Then I should be on the review order page
      	
  Scenario: View Billing Address from the Review Order page
    Given I have created a valid order
    And I am on the order review page
    When I follow "View or Edit Billing Address"
    Then I should be on the page to edit my billing address
    When I press "Return"
    Then I should be on the review order page
    And I should see "Your billing address has not been changed."
      	
  Scenario: Valid Edit Billing Address from the Review Order page
    Given I have created a valid order
    And I am on the order review page
    When I follow "View or Edit Billing Address"
    Then I should be on the page to edit my billing address
    When I press "Update"
    Then I should be on the review order page
    And I should see "Your billing address has been updated."
      		
  Scenario: Invalid Edit Billing Address from the Review Order page
    Given I have created a valid order
    And I am on the order review page
    When I follow "View or Edit Billing Address"
    Then I should be on the page to edit my billing address
    When I do an invalid change to my "billing" address
    And I press "Update"
    Then I should see "Update Billing Information"
    And I should see "Your billing address update failed."

  Scenario: View Shipping Address from the Review Order page
    Given I have created a valid order
    And I am on the order review page
    When I follow "View or Edit Shipping Address"
    Then I should be on the page to edit my shipping address
    When I press "Return"
    Then I should be on the review order page
    And I should see "Your shipping address has not been changed."

  Scenario: Edit Shipping Address from the Review Order page
    Given I have created a valid order
    And I am on the order review page
    When I follow "View or Edit Shipping Address"
    Then I should be on the page to edit my shipping address
    When I press "Update"
    Then I should be on the review order page
    And I should see "Your shipping address has been updated."
      
  Scenario: Invalid Edit Shipping Address from the Review Order page
    Given I have created a valid order
    And I am on the order review page
    When I follow "View or Edit Shipping Address"
    Then I should be on the page to edit my shipping address
    When I do an invalid change to my "shipping" address
    And I press "Update"
    Then I should see "Update Shipping Information"
    And I should see "Your shipping address update failed."
    
  # Scenarios for editing billing address from after seeing the new order page
	
  # Scenarios for editing shipping address from after seeing the new order page
	
  # Scenarios for entering invalid billing address
	
  # Scenarios for entering invalid shipping address
	
  # Scenarios for editing billing address with invalid fields
	
  # Scenarios for editing shipping address with invalid fields
	
  # Scenarios for getting the billing/shipping address from PayPal Express
	
	
	
	
	




  
