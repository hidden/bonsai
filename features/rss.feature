Feature: Wiki
    In order to share rss data
    A user
    Should be able to see rss changes


Scenario: check if RSS works properly
    When I go to the main page
    And I login as "johno"
    And I fill in "title" with "Root page"
    And I fill in "body" with "Root body!"
    And I fill in "summary" with "A change"
    And I select "PeWe Layout" from "layout"
    And I press "Create"
    And I go to /?rss
    Then I should see "Root page changes"
    When I go to the main page
    And I follow "Edit"
    And I fill in "title" with "Some NEW title"
    And I press "Save"
    Then I should see "Page successfully updated."
    And I go to /?rss
    Then I should see "Some NEW title changes"





    