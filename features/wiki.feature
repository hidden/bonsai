Feature: Wiki
    In order to share content on wiki
    A user
    Should be able to create and manage wiki pages

Scenario: Anonymous user visits a fresh wiki
    When I go to the main page
    Then I should see "Page does not exists, but you must login to edit it."

Scenario: Anonymous user logs in successfully
    When I go to the main page
    And I fill in "username" with "johno"
    And I fill in "password" with "johno"
    And I press "Log in"
    Then I should see "You have successfully logged in."
    Then I should see "Logged in as: johno"

Scenario: Anonymous user logs in successfully
    When I go to the main page
    And I fill in "username" with "johno"
    And I fill in "password" with "something bad"
    And I press "Log in"
    Then I should see "Login failed. Invalid credentials."
    And I should not see "Logged in as:"

Scenario: Logged user visits a fresh wiki and creates first page
    When I go to the main page
    And I login as "johno"
    Then I should see "Page does not exits yet. Do you want to create it?"
    And I fill in "title" with "Hello world!"
    And I fill in "body" with "Hello universe!"
    And I press "Create"
    Then I should see "Page succesfully created."
    And I should see "Hello world!"
    And I should see "Hello universe!"
