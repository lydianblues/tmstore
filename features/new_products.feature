Feature: Create new Products
  In order to administer the store
  As a administrator
  I want to create and delete products

Scenario: Create a Product using the Form
  Given I am logged in as admin
	And a product family "Junk Food"
  When I create a product "Cheese Balls" in the "Junk Food" product family
	And I go to the manage products page
	And I press "Search"
  Then I should see "Cheese Balls" in the "Junk Food" product family
	And I should see 1 product in the table