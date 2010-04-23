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
    And I should see "This is a text of a new page part"

  Scenario: User creates a page with header and pewe layout
    When I create "/" page with title "Root page" body "Root body!" and "PeWe Layout" layout
    And I add "navigation" page part with text "This is a header"
    Then I should see "This is a header" within "#nav"

  Scenario: User create a page part and then delete, it should not be seen from now on
    When I create "/" page
    And I add "testpage" page part with text "This is a header"
    Then I should see "Page part successfully added."
    Then I should see "This is a header"
    When I follow "Edit"
    And I delete "testpage" page part
    Then I should not see "testpage"
    And I follow "page_history"
    And I should see "r3"
    

  Scenario: User create a page part and rename it
    When I create "/" page
    And I add "testpage" page part with text "This is a header"
    Then I should see "This is a header"
    And I edit "testpage" page part with text "testpage2"
    Then I should see "Page successfully updated."
    When I follow "Edit"
    Then I should see "testpage2"

  Scenario: User adds page part and preview the page
    When I create "/" page
    When I create "/nested" page with title "Nested page" body "Nested body!"
    And I add "second_part" page part with text "This is a second part" without saving
    And I press "Preview"
    Then I should see "This is preview"
    And I should see "Nested body!"
    And I should see "This is a second part"
    When I go to /nested
    Then I should see "Nested body!"
    And I should not see "This is a second part"

  @wip  
  Scenario: User change ordering of page parts
    When I create "/" page
    And I add "Erika" page part with text "Erika"
    And I add "Anna" page part with text "Arabela"
    And I should see "Some content. Erika Arabela"
    And I change ordering of page parts to "name"
    Then I should see "Arabela Some content. Erika" 




