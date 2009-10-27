Feature: Wiki
  In order to share content on wiki
  A user
  Should be able to create and manage wiki pages

  Scenario: Anonymous user visits a fresh wiki
    When I go to the main page
    Then I should see "Permission denied."

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
    And I fill in "summary" with "init"
    And I press "Create"
    Then I should see "Page successfully created."
    And I should see "Hello world!"
    And I should see "Hello universe!"

  Scenario: User wants to edit a page he created
    When I go to the main page
    And I login as "johno"
    And I fill in "title" with "Hello world!"
    And I fill in "body" with "Hello universe!"
    And I fill in "summary" with "short summary"
    And I press "Create"
    And I follow "edit"
    And I fill in "title" with "Changed title"
    And I fill in "parts[body]" with "Changed body"
    And I fill in "summary" with "short summary"
    And I press "Save"
    Then I should see "Page successfully updated."
    And I should see "Changed body"

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
    And I fill in "summary" with "markdown test"
    And I press "Create"
    And I should see "emphasis" within "em"

  Scenario: User wants to see the page history
    Given that a "main" page with multiple revisions exist
    When I go to the main page
    And I login as "johno"
    And I go to the main page
    And I follow "history"
    Then I should see "Changes for page: main"
    And I should see "This is first summary"
    And I should see "This is second summary"

  Scenario: User wants to see the diff of two page revisions
    Given that a "main" page with multiple revisions exist
    When I go to the main page
    And I login as "johno"
    And I go to the main page
    And I follow "history"
    And I choose "first_revision_1"
    And I choose "second_revision_2"
    And I press "compare selected versions"
    Then I should see "This is second revision" within ".line-changed"

  Scenario: User wants to revert a revision
    Given that a "main" page with multiple revisions exist
    When I go to the main page
    And I login as "johno"
    And I follow "history"
    When I follow "Revert to revision 1"
    And I press "Save"
    Then I should see "Page successfully updated."
    And I should see "This is first revision"

  Scenario: User wants to add a new page part
    Given that a "main" page with multiple revisions exist
    When I go to the main page
    And I login as "johno"
    And I follow "edit"
    And I fill in "new_page_part_name" with "menu"
    And I fill in "new_page_part_text" with "This is a text of a new page part"
    And I press "Add new page part"
    Then I should see "Page part successfully added."
    And I should see "menu"
    And I should see "This is a text of a new page part"
    And I should not see "Page successfully updated."

  Scenario: User wants to show a revision of simple page
    Given that a "main" page with multiple revisions exist
    When I go to the main page
    And I login as "johno"
    And I follow "history"
    When I follow "Show page from revision 1"
    Then I should see "This is first revision"

  Scenario: User wants to show a revision of complex page
    When I go to the main page
    And I login as "johno"
    And I fill in "title" with "Root page"
    And I fill in "body" with "Root body!"
    And I fill in "summary" with "A change"
    And I select "PeWe Layout" from "layout"
    And I press "Create"
    When I follow "edit"
    And I fill in "new_page_part_name" with "navigation"
    And I fill in "new_page_part_text" with "This is a header"
    And I press "Add new page part"
    And I follow "View"
    And I follow "history"
    When I follow "Show page from revision 1"
    Then I should not see "This is a header"
    And I should see "Root body!"