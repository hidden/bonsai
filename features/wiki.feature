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

Scenario: User wants to log out.
    When I go to the main page
    And I login as "johno"
    And I follow "Log out"
    Then I should see "Logout successfull."
    And I should not see "Logged in as:"

Scenario: Logged user visits a fresh wiki and creates first page
    When I go to the main page
    And I login as "johno"
    Then I should see "Page does not exists. Do you want to create it?"
    And I fill in "title" with "Hello world!"
    And I fill in "body" with "Hello universe!"
    And I press "Create"
    Then I should see "Page successfully created."
    And I should see "Hello world!"
    And I should see "Hello universe!"

Scenario: User wants to edit a page

Scenario: User wants to create a wiki page without existing parent
    When I go to the main page
    And I login as "johno"
    And I go to a page without parent
    Then I should see "Parent page does not exists."

Scenario: User uses markdown syntax on wiki page
    When I go to the main page
    When I login as "johno"
    And I fill in "title" with "Markdown Page"
    And I fill in "body" with "Text with *emphasis*."
    And I press "Create"
    Then I should see "Text with <em>emphasis</em>." in html code

Scenario: Wiki page viewable by one user
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And page "/" is viewable by "johno"
    When I logout
    And I go to the main page
    Then I should see "Permission denied."
    When I login as "crutch"
    Then I should see "Permission denied."
    When I login as "johno"
    Then I should see "Some content."
