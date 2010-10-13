Feature: Administer products
  In order to set up the store
  As a administrator
  I want to manage products

  Background:
    Given I am logged in as admin
    And a category tree:
      | parent | child1 | child2 |
      | root   | A      | B      |
      | A      | C      | D      |
      | C      | E      |        |
      | D      | F      | G      |
      | F      | H      | I      |

  Scenario: Products are only visible along a path from leaf to root
    Given a product family "Junk Food" in the "/A/D/F/I" category
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/A/D/F/I"
    Then I should see "Cheese Puffs" on these category paths:
      | /A/D/F/I   |
      | /A/D/F     |
      | /A/D       |
      | /A         |
      | /          |
    And I should not see "Cheese Puffs" on these category paths:
      | /A/D/F/H   |
      | /A/C/E     |
      | /A/D/G     |
      | /A/C       |
      | /B         |

  Scenario: You should be able to create a fifth-level category
    When I visit the admin category page for the "/A/D/F/I" category path
    Then I should see "There are no Subcategories."
    And I should see "Create Subcategory"


    



