Feature: Registration
  In order to access wiki without LDAP account
  A user
  Should be able to register and log in

  Scenario: Anonymous user make registration to wiki
    When I go to the main page
    And I follow "Registration"
    Then I should see "New account"
    And I fill in "username" with "michal"
    And I fill in "password" with "heslo2"
    And I fill in "password_confirmation" with "heslo2"
    And I press "Register"
    Then I should see "New account was created."