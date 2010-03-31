Feature: Registration
  In order to access wiki without LDAP account
  A user
  Should be able to register and log in

  Scenario: Anonymous user make registration to wiki
    When I go to the main page
    And I follow "Registration"
    Then I should see "New account"
    And I fill in "Username" with "michal"
    And I fill in "Name" with "Michal Novotny"
    And I fill in "Password" with "heslo2"
    And I fill in "Password confirmation" with "heslo2"
    And I press "Submit registration"
    Then I should see "Registration successfully completed!"
    And I fill in "username" with "michal"
    And I fill in "password" with "heslo2"
    And I press "Log in"
    Then I should see "You have successfully logged in."

  Scenario: Anonymoou user fail registration
    When I go to the main page
    And I follow "Registration"
    And I fill in "Username" with "martin"
    And I fill in "Name" with "Martin Kovac"
    And I fill in "Password" with "heslo"
    And I fill in "Password confirmation" with "ineheslo"
    And I press "Submit registration"
    Then I should see "Registration unsuccessful - please check form"
    And I should see "Password doesn't match confirmation"

  Scenario: Logged user should not access registration page
    When I login as "johno"
    And I go to the registration page
    Then I should not see "New account"