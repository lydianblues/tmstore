Feature: Administer products
  In order to set up the store
  As a administrator
  I want to manage products

  Scenario: View a newly created product in the root category
    Given a product family "Junk Food" in the "/" category
    And I am logged in as admin
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/"
    And I visit the products page for the "/" category path
    Then I should see "Cheese Puffs"

  Scenario: View a newly created visible product in a top-level category
    Given a category with category path "/A"
    And a product family "Junk Food" in the "/A" category
    And I am logged in as admin
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/A"
    And I visit the products page for the "/A" category path
    Then I should see "Cheese Puffs"
    When I visit the products page for the "/" category path
    Then I should see "Cheese Puffs" 

  Scenario: View a newly created visible product in a second-level category
    Given a category with category path "/A/B"
    And a product family "Junk Food" in the "/A/B" category
    And I am logged in as admin
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/A/B"
    And I visit the products page for the "/A/B" category path
    Then I should see "Cheese Puffs"     
    When I visit the products page for the "/A" category path
    Then I should see "Cheese Puffs"     
    When I visit the products page for the "/" category path
    Then I should see "Cheese Puffs" 

  Scenario: View a newly created visible product in a third-level category
    Given a category with category path "/A/B/C"
    And a product family "Junk Food" in the "/A/B/C" category
    And I am logged in as admin
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/A/B/C"
    And I visit the products page for the "/A/B/C" category path
    Then I should see "Cheese Puffs"     
    When I visit the products page for the "/A/B" category path
    Then I should see "Cheese Puffs"     
    When I visit the products page for the "/A" category path
    Then I should see "Cheese Puffs" 
    When I visit the products page for the "/" category path
    Then I should see "Cheese Puffs" 

  Scenario: View a newly created visible product in a fourth-level category
    Given a category with category path "/A/B/C/D"
    And a product family "Junk Food" in the "/A/B/C/D" category
    And I am logged in as admin
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/A/B/C/D"
    And I visit the products page for the "/A/B/C/D" category path
    Then I should see "Cheese Puffs"     
    And I visit the products page for the "/A/B/C" category path
    Then I should see "Cheese Puffs"     
    When I visit the products page for the "/A/B" category path
    Then I should see "Cheese Puffs"     
    When I visit the products page for the "/A" category path
    Then I should see "Cheese Puffs" 
    When I visit the products page for the "/" category path
    Then I should see "Cheese Puffs" 

  Scenario: Products are only visible along a path from leaf to root
    Given a category with category path "/A/B/C/D"
    And a category with category path "/A/B/C/E"
    And a category with category path "/A/B/F"
    And a category with category path "/A/G"
    And a category with category path "/H"
    And a product family "Junk Food" in the "/A/B/C/D" category
    And I am logged in as admin
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/A/B/C/D"
    And I visit the products page for the "/A/B/C/D" category path
    Then I should see "Cheese Puffs"     
    And I visit the products page for the "/A/B/C/E" category path
    Then I should not see "Cheese Puffs"     
    And I visit the products page for the "/A/B/C" category path
    Then I should see "Cheese Puffs"     
    And I visit the products page for the "/A/B/F" category path
    Then I should not see "Cheese Puffs"     
    When I visit the products page for the "/A/B" category path
    Then I should see "Cheese Puffs"     
    When I visit the products page for the "/A/G" category path
    Then I should not see "Cheese Puffs"     
    When I visit the products page for the "/A" category path
    Then I should see "Cheese Puffs" 
    When I visit the products page for the "/H" category path
    Then I should not see "Cheese Puffs" 
    When I visit the products page for the "/" category path
    Then I should see "Cheese Puffs"

  Scenario: You should not be able to create a fifth-level category
    Given I am logged in as admin
    And a category with category path "/A/B/C/D"
    When I visit the admin category page for the "/A/B/C/D" category path
    Then I should see "There are no Subcategories."
    And I should not see "Create Subcategory"


    



