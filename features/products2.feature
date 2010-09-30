Feature: Administer products
  In order to set up the store
  As a administrator
  I want to manage products

  Background:
    Given I am logged in as admin

  Scenario: View a newly created product in the root category
    Given a product family "Junk Food" in the "/" category
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/"
    And I visit the products page for the "/" category path
    Then I should see "Cheese Puffs"

  Scenario: View a newly created visible product in a top-level category
    Given a category with category path "/A"
    And a product family "Junk Food" in the "/A" category
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/A"
    Then I should see "Cheese Puffs" on these category paths:
      | /  |
      | /A |

  Scenario: View a newly created visible product in a second-level category
    Given a category with category path "/A/B"
    And a product family "Junk Food" in the "/A/B" category
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/A/B"
    Then I should see "Cheese Puffs" on these category paths:
      | /    |
      | /A   |
      | /A/B |

  Scenario: View a newly created visible product in a third-level category
    Given a category with category path "/A/B/C"
    And a product family "Junk Food" in the "/A/B/C" category
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/A/B/C"
    Then I should see "Cheese Puffs" on these category paths:
      | /      |
      | /A     |
      | /A/B   |
      | /A/B/C |

  Scenario: View a newly created visible product in a fourth-level category
    Given a category with category path "/A/B/C/D"
    Given a product family "Junk Food" in the "/A/B/C/D" category
    When I create a product "Cheese Puffs" in the "Junk Food" product family with visibility path "/A/B/C/D"
    Then I should see "Cheese Puffs" on these category paths:
      | /        |
      | /A       |
      | /A/B     |
      | /A/B/C   |
      | /A/B/C/D |

