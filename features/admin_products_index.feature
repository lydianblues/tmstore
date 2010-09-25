Feature: Manage Selection and Sorting of Products
  In order to administer the store
  As a administrator
  I want to select and sort products

Background:
	Given I am logged in as admin
	Given a product family "meat"
	And a product family "veggie"
  And the following products
	  | name    | product_family | price | qty_in_stock | qty_on_order | qty_low_threshold | description    | key_words    |
	  | steak   | meat           | $6.22 | 7            | 5            | 2                 | bad for you    | juicy fatty  |
	  | chicken | meat           | $4.00 | 12           | 0            | 5                 | better for you | juicy fatty  |
	  | pork    | meat           | $5.50 | 0            | 3            | 2                 | still bad      | juicy piggy  |
	  | peas    | veggie         | $2.34 | 40           | 20           | 50                | fresh frozen   | round frozen |
	  | corn    | veggie         | $0.99 | 200          | 0            | 50                | yellow not bad | frozen ears  |
	And I am on the manage products page

Scenario: Product Selection with no parameters specified
	When I press "Search"
  Then I should see "corn" in the "veggie" product family
	And I should see 5 products in the table

Scenario: Product Selection by Product Family 1
	When I fill in "Product Family" with "meat"
	And I press "Search"
  Then I should see 3 products in the table

Scenario: Product Selection by Product Family 2
	When I fill in "Product Family" with "veggie"
	And I press "Search"
  Then I should see 2 products in the table

Scenario: Product Selection by "Out of Stock 1"
	When I fill in "Product Family" with "veggie"
	And I choose "Out of Stock"
	And I press "Search"
	Then I should see "There are no matching products."
	
Scenario: Product Selection by "Out of Stock 2"
	When I fill in "Product Family" with "meat"
	And I choose "Out of Stock"
	And I press "Search"
	Then I should see "pork" in the "meat" product family
	And I should see 1 product in the table
	
Scenario: Product Selection by "Low Stock"
	When I choose "Low Stock"
	And I press "Search"
	Then I should see "peas" in the "veggie" product family
	Then I should see "pork" in the "meat" product family
	And I should see 2 products in the table
	





