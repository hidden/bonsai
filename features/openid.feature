Feature: OpenID
  In order to access wiki
  A user
  Should be able to log in using OpenID

  Background:
    Given OpenID is used

  Scenario: check if openid element exist
    When I go to the main page
    Then the source should contain tag "input" with id "openid_identifier"

  Scenario: user wants to log in using good openid identifier
    When I go to the main page
    And I login as "http://test.myopenid.com" using OpenID
    Then I should see "You have successfully logged in."

  Scenario: user wants to log in using bad openid identifier
    When I go to the main page
    And I login as "johno" using OpenID
    Then I should see "Login failed. Invalid credentials."

  Scenario: user wants to log out while using OpenID
    When I go to the main page
    And I login as "http://test.myopenid.com" using OpenID
    And I follow "Log out"
    Then I should see "Logout successfull."
    And I should not see "Logged in as:"
    