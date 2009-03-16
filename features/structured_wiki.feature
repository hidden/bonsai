Feature: Wiki layouting and many page parts
    In order to have structured pages on wiki
    A user
    Should be able to define layout and edit page parts

Scenario: User creates a page with header, footer and body
    When I go to the main page
    And I login as "johno"
    And I fill in "title" with "Root page"
    And I fill in "body" with "Root body!"
    And I fill in "summary" with "A change"
    And I select "PeWe Layout" from "layout"
    And I press "Create"
    Then I should see "<div id="header"></div>" in html code
    When I follow "edit"
    And I fill in "new_page_part_name" with "header"
    And I fill in "new_page_part_text" with "This is a header"
    And I press "Add new page part"
    When I go to the main page
    Then I should see "<div id="header"><p>This is a header</p></div>" in html code