Feature: LDAP
  In order to access wiki
  A user
  Should be able to log in using LDAP

  Background:
    Given LDAP is used

  Scenario: Anonymous user visits a fresh wiki
    When I go to the main page
    Then I should see "Permission denied."

  Scenario: Anonymous user logs in successfully
    When I go to the main page
    And I login as "johno"
    Then I should see "You have successfully logged in."
    Then I should see "johno (johno) | Log out"

  Scenario: Anonymous user logs not successfully
    When I go to the main page
    And I login as "johno" using password "badpass"
    Then I should see "Login failed. Invalid credentials."
    And I should not see "Logged in as:"

  Scenario: User wants to log out.
    When I go to the main page
    And I login as "johno"
    And I follow "Log out"
    Then I should see "Logout successfull."
    And I should not see "Logged in as:"

  Scenario: User logs in successfully with stored password
    Given user "johno" has stored password "heslo"
    When I go to the main page
    And I fill in "username" with "johno"
    And I fill in "password" with "heslo"
    And I press "Log in"
    Then I should see "You have successfully logged in."
    Then I should see "johno (johno) | Log out"