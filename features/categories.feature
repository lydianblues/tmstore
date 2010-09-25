Feature: Administer categories
  In order to set up the store
  As a administrator
  I want to manage categories

  Scenario: Create a New Category
    Given I am logged in as admin
    And I am on the manage categories page
    When I follow category command link "Add a New Top Level Category"
    And I fill in "New Category Name" with "Rodeo Equipment"
    And I press "Create"
    And I go to the manage categories page
    Then I should see the "Rodeo Equipment" category

  Scenario: Add a Product Family to a Category
    Given I am logged in as admin
    And a product family "Rodeo Equipment"
    And a top-level category "Lasso"
    And I am on the manage categories page for "Rodeo Equipment"
    When I fill in "Name of Product Family" with "Lasso"
    And I press "Add"
    Then I should see the "Lasso" product family

  Scenario: Add a new child to a top-level category
    Given a product family "Junk Food"
    And a product "Cheese Balls" in the "Junk Food" product family
    And a top-level category "Health Inhibitors"
    And the "Junk Food" product family is in the "Health Inhibitors" category
    And I add the product "Cheese Balls" to the "Health Inhibitors" category
    When I visit the products page for category "root"
    Then I should see "Cheese Balls"

  Scenario: Add a new child to a top-level category, II
    Given a product family "Junk Food"
    And a product "Cheese Balls" in the "Junk Food" product family
    And a top-level category "Health Inhibitors"
    And the "Junk Food" product family is in the "Health Inhibitors" category
    And I add the product "Cheese Balls" to the "Health Inhibitors" category
    When I visit the products page for category "Health Inhibitors"
    Then show me the page
    And I should see "Cheese Balls"

  Scenario: Add a child category to a leaf
    Given a product family "Junk Food"
    And a product "Cheese Balls" in the "Junk Food" product family
    And a top-level category "Health Inhibitors"
    And the "Junk Food" product family is in the "Health Inhibitors" category
    And I add the product "Cheese Balls" to the "Health Inhibitors" category
    And I add a child category "Snacks" to parent "Health Inhibitors"
    When I visit the products page for category "Snacks"
    Then I should see "Cheese Balls"

    Scenario: Add a child category to a leaf, remove parent
      Given a product family "Junk Food"
      And a product "Cheese Balls" in the "Junk Food" product family
      And a top-level category "Health Inhibitors"
      And the "Junk Food" product family is in the "Health Inhibitors" category
      And I add the product "Cheese Balls" to the "Health Inhibitors" category
      And I add a child category "Snacks" to parent "Health Inhibitors"
      And I remove category "Health Inhibitors"
      When I visit the products page for category "Snacks"
      Then I should see "Cheese Balls"
      When I visit the products page for category "root"
      Then I should see "Cheese Balls"

