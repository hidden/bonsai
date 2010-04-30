Feature: Registration
  In order to access wiki without LDAP account
  A user
  Should be able to register and log in

  Background:
    Given the user registration is enabled

  Scenario: Anonymous user make registration to wiki
    When I go to the main page
    And I follow "Registration"
    Then I should see "New account"
    And I make registration with login "michal", name "Michal Novotny", password "heslo2" and password confrimation "heslo2"
    Then I should see "Registration successfully completed!"
    And I fill in "username" with "michal"
    And I fill in "password" with "heslo2"
    And I press "Log in"
    Then I should see "Your account is not activated. Contact administrator."

  Scenario: Anonymoou user fail registration
    When I go to the main page
    And I follow "Registration"
    And I make registration with login "martin", name "Martin Kovac", password "heslo" and password confrimation "ineheslo"
    Then I should see "Registration unsuccessful - please check form"
    And I should see "Password doesn't match confirmation"

  Scenario: Logged user should not access registration page
    When I login as "johno"
    And I go to the registration page
    Then I should not see "New account"

  Scenario: User want to visit registration page when it is disabled
    When the user registration is disabled
    And I go to the main page
    And I should not see "Registration"
    When I go to the registration page
    Then I should see "User registrations are disabled."