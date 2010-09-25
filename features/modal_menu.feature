Feature: Modal Menu
  In order to negotiate and find products
  As an ordinary user
  I want to navigate by category or by filter

Scenario: Filters are shown when root has no subcategories
  Given a product family "Junk Food"
    And an attribute "Color"
    And the "Color" attribute is in the "Junk Food" product family
    And the "Junk Food" product family is in the "root" category
    And a product "Cheese Balls" in the "Junk Food" product family
  When I go to the products page
  Then I should see the filter menu
  And I should not see the category menu
	
Scenario: Categories are shown when root has no filters
  Given a top-level category "Health Inhibitors"
  When I go to the products page
  Then I should not see the filter menu
    And I should see the category menu
	
Scenario: Root has both filters and subcategories
  Given a top-level category "Health Inhibitors"
    And a product family "Junk Food"
    And an attribute "Color"
    And the "Color" attribute is in the "Junk Food" product family
    And the "Junk Food" product family is in the "root" category
  When I go to the products page
  Then I should see "Available Products"

	
  
