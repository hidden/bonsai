Feature: Wiki
  In order to use openid authentification
  A user
  Should be able to log in using openid

Background:
    Given OpenID is used

Scenario: check if openid element exist
    When I go to the main page
    Then the source should contain tag "input" with id "openid_identifier"
  
Scenario: user wants to log in using bad openid identifier
    When I go to the main page
    And I log in as "johno" using OpenID
    Then I should see "Login failed. Invalid credentials."
    
Scenario: user wants to log in using good openid identifier
    When I go to the main page
    And I log in as "http://test.myopenid.com" using OpenID
    Then I should see "You have successfully logged in."


