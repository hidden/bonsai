Feature: Wiki
  In order to share content on wiki
  A user
  Should be able to see history of changes

  Background:
    Given I am logged in

    Scenario: User wants to see the diff of two page revisions long version
    When I create "/" page
    When I follow "edit"
    And I fill in "new_page_part_name" with "first"
    And I fill in "new_page_part_text" with "This is first revision"
    And I press "Save"
    And I follow "history"
    And I compare revision "first_revision_1" with "second_revision_2"
    Then I should see "This is first revision" within ".line.addition"

  Scenario: User wants to revert a revision
    Given I am not logged in
    And that a "main" page with multiple revisions exist
    And I am logged in
    And I follow "history"
    When I follow "Revert to revision 1"
    And I press "Save"
    Then I should see "Page successfully updated."
    And I should see "This is first revision"

  Scenario: User wants to show a revision of simple page
    Given I am not logged in
    And that a "main" page with multiple revisions exist
    And I am logged in
    And I follow "history"
    When I follow "Show page from revision 1"
    Then I should see "This is first revision"
    
  Scenario: User wants to show a revision of page with inherited pagepart
    When I create "/" page
    When I follow "edit"
    And I select "PeWe Layout" from "layout"
    And I press "Save"
    When I follow "edit"
    And I fill in "new_page_part_name" with "caption"
    And I fill in "new_page_part_text" with "This is original caption."
    And I press "Save"
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
  Scenario: User wants to show a revision of complex page
    When I create "/" page with title "Root page" body "Root body!" and "PeWe Layout" layout
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

  Scenario: User create code text in page
    When I create "/" page with title "hello world" string body
    """
        <?php echo 'hello world'; ?>
    {:class=php}
    """
    Then I should see "<?php echo 'hello world'; ?>" within "body"
  