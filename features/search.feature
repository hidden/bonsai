Feature: Wiki fulltext search

  Background:
    Given I am logged in

  Scenario: User search for some non existing data
    When I create "/" page with title "korenova stranka"
    And I go to the main page
    Then I should see "korenova stranka"
    When indexes are updated
    And I search for "korstranka"
    Then I should not see "korstranka"
    
   Scenario: User search for some existing data
    When I create "/" page with title "korenova stranka"
    And I go to the main page
    Then I should see "korenova stranka"
    When indexes are updated
    And I search for "korenova stranka"
    Then I should see "korenova stranka"

