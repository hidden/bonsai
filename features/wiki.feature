Feature: Wiki
  In order to share content on wiki
  A user
  Should be able to create and manage wiki pages

  Scenario: Anonymous user visits a fresh wiki
    When I go to the main page
    Then I should see "Permission denied."

  Scenario: Anonymous user logs in successfully
    When I go to the main page
    And I login as "johno"
    Then I should see "You have successfully logged in."
    Then I should see "Logged in as: johno"

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

  Scenario: Logged user visits a fresh wiki and creates first page
    When I go to the main page
    And I login as "johno"
    Then I should see "Page does not exists. Do you want to create it?"
    And I create "/" page with title "Hello world" body "Hello universe"
    Then I should see "Page successfully created."
    And I should see "Hello world"
    And I should see "Hello universe"

  Scenario: User wants to edit a page he created
    When I go to the main page
    And I login as "johno"
    And I create "/" page with title "Hello world" body "Hello universe"
    And I edit "/" page with title "Changed title" body "Changed body"
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
    And I create "/" page with title "Markdown Page" body "Text with *emphasis*."
    Then I should see "emphasis" within "em"


  Scenario: User wants to see the page history
    Given that a "main" page with multiple revisions exist
    When I go to the main page
    And I login as "johno"
    And I go to the main page
    And I follow "history"
    Then I should see "Changes for page: main"
    And I should see "This is first summary"
    And I should see "This is second summary"
  #  Then I must see "Changes for page: main & This is first summary & This is second summary"


  Scenario: User wants to see the diff of two page revisions
    Given that a "main" page with multiple revisions exist
    When I go to the main page
    And I login as "johno"
    And I go to the main page
    And I follow "history"
    And I compare revision "first_revision_1" with "second_revision_2"
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

  Scenario: User wants to show a revision of simple page
    Given that a "main" page with multiple revisions exist
    When I go to the main page
    And I login as "johno"
    And I follow "history"
    When I follow "Show page from revision 1"
    Then I should see "This is first revision"

  @wip  
  Scenario: User wants to show a revision of complex page
    When I go to the main page
    And I login as "johno"
    And I create "/" page with title "Root page" body "Root body!" and "PeWe Layout" layout
    Then I should see "Root body!"
    And I add "navigation" page part with text "This is a header"
    And I follow "View"
    Then I should see "This is a header"
    And I should see "Root body!"
    When I follow "History"
    And I follow "Show page from revision 1"
    Then I should see "Root body!"
    And I should not see "This is a header"
    When I follow "History"
    And I follow "Show page from revision 2"
    Then I should see "This is a header"
    And I should see "Root body!"
    
  Scenario: User wants to show a revision of page with inherited pagepart
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    When I follow "edit"
    And I select "PeWe Layout" from "layout"
    And I press "Save"
    When I follow "edit"
    And I fill in "new_page_part_name" with "caption"
    And I fill in "new_page_part_text" with "This is original caption."
    And I press "Add new page part"
    And I create "/test" page
    And I go to the main page
    When I follow "edit"
    And I fill in "parts_caption" with "This is modified caption."
    And I press "Save"
    When I go to the test page
    And I follow "history"
    And I follow "Show page from revision 1"
    Then I should see "This is original caption."

  @wip
  Scenario: User wants to go to page without /
    When I go to the main page
    And I login as "johno"
    And I create "/" page with title "Root page" body "Root body!"
    And I create "/nested/" page with title "Nested page" body "[linka](test_file.txt)"
    And I follow "edit"
    And I attach the file at "test_file.txt" to "uploaded_file_uploaded_data"
    And I press "Upload"
    And I go to /nested
    When I follow "linka"
    Then I should not see "File not found"
