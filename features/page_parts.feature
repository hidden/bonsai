Feature: Wiki layouting and many page parts
  In order to have structured pages on wiki
  A user
  Should be able to define layout and edit page parts

  Background:
      Given I am logged in

  Scenario: User wants to add a new page part
     Given I am not logged in
     And that a "main" page with multiple revisions exist
     When I go to the main page
     And I login as "johno"
     And I add "menu" page part with text "This is a text of a new page part"
     Then I should see "Page part successfully added."
     And I should see "menu"
     And I should see "This is a text of a new page part"
     And I should not see "Page successfully updated."

  Scenario: User creates a page with header and pewe layout
    When I create "/" page with title "Root page" body "Root body!" and "PeWe Layout" layout
    And I add "navigation" page part with text "This is a header"
    And I follow "View"
    Then I should see "This is a header" within "#nav"

  Scenario: User create a page part and then delete, it should not be seen from now on
    When I create "/" page
    And I add "testpage" page part with text "This is a header"
    Then I should see "Page part successfully added."
    Then I should see "This is a header"
    When I delete "testpage" page part
    Then I should see "Page successfully updated."
    When I follow "Edit"
    Then I should not see "testpage"

  Scenario: User create a page part and rename it
    When I create "/" page
    And I add "testpage" page part with text "This is a header"
    Then I should see "This is a header"
    And I edit "testpage" page part with text "testpage2"
    Then I should see "Page successfully updated."
    When I follow "Edit"
    Then I should see "testpage2"

