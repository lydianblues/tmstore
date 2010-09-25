Feature: Administer Accounts
  In order to manage user accounts
  As a administrator
  I want to view and edit user accounts

Scenario: Let administrator view user accounts
  Given the following user records
		 | login | password | admin |
		 | bob   | secret   | false |
		 | admin2 | secret   | true  |
	And I am logged in as "admin2" with password "secret"
  When I view the profile page for "bob"
  Then I should see the show account page for "bob"

Scenario: Let administrator edit user accounts
  Given the following user records
		 | login | password | admin |
		 | bob   | secret   | false |
		 | admin2 | secret   | true  |
	And I am logged in as "admin2" with password "secret"
  When I visit the edit profile page for "bob"
  Then I should see the edit account page for "bob"