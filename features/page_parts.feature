Feature: Wiki layouting and many page parts
  In order to have structured pages on wiki
  A user
  Should be able to define layout and edit page parts

  Scenario: User creates a page with header and pewe layout
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
    Then I should see "This is a header" within "#nav"

  Scenario: User create a page part and then delete, it should not be seen from now on
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I follow "Edit"
    And I fill in "new_page_part_name" with "testpage"
    And I fill in "new_page_part_text" with "This is a header"
    And I press "Add new page part"
    Then I should see "Page part successfully added."
    And I follow "View"
    Then I should see "Some title"
    When I follow "Edit"
    And I check "is_deleted_testpage"
    And I press "Save"
    Then I should see "Page successfully updated."
    When I follow "Edit"
    Then I should not see "testpage"
        
    