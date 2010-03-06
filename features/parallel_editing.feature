Feature: Parallel editing
  In order to speed up editation
  A user
  Should be able to edit page with other users

  Background:
    Given I am logged in
    And I create "/" page    

  Scenario: Two users edit different page parts simultaneously    
    When I add "header" page part with text "This a header"
    And I go to the main page
    And I follow "Edit"
    And someone else changes page part "body" at "/" to "This is new content from someone"
    And I fill in "parts_header" with "This is my new header!"
    And I press "Save"
    Then I should see "This is my new header!"
    And I should see "This is new content from someone"

  #@wip
  #Scenario: Two users edit same page parts simultaneusly 
    

