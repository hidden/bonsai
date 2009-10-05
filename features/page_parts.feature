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
    