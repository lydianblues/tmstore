Feature: View Recent Orders
  In order to view my orders
  As a logged in user
  I want to see a correct and complete list of my orders

@wip
Scenario: View only my orders
  Given I am logged in as "Bob"
  And the store contains purchased orders for "Alice"
  When I view the "Recent Orders" page
  Then I should not see orders for "Alice"

Scenario: View only complete orders
  Given I am logged in as "Bob"
  When I view the "Recent Orders" page
  Then I should not see orders in the "shopping" state

