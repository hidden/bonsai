Feature: Wiki
  In order to share content on wiki
  A user
  Should be able to create and manage wiki pages

  Background:
    Given I am logged in

  Scenario: Logged user visits a fresh wiki and creates first page
    Then I should see "Page does not exists. Do you want to create it?"
    And I create "/" page with title "Hello world" body "Hello universe"
    Then I should see "Page successfully created."
    And I should see "Hello world"
    And I should see "Hello universe"

  Scenario: User wants to edit a page he created
    When I create "/" page with title "Hello world" body "Hello universe"
    And I edit "/" page with title "Changed title" body "Changed body"
    Then I should see "Page successfully updated."
    And I should see "Changed body"

  Scenario: User wants to create a wiki page without existing parent
    When I go to a page without parent
    Then I should see "Parent page does not exists."

  Scenario: User uses markdown syntax on wiki page
    When I create "/" page with title "Markdown Page" body "Text with *emphasis*."
    Then I should see "emphasis" within "em"


  Scenario: User wants to see the page history
    Given I am not logged in
    And that a "main" page with multiple revisions exist
    And I am logged in
    And I follow "history"
    Then I should see "Changes for page: main"
    And I should see "This is first summary"
    And I should see "This is second summary"
  #  Then I must see "Changes for page: main & This is first summary & This is second summary"


  Scenario: User with rights wants to view subpages tree
    When I create "/" page
    And I create "/title1" page with title "Some title1"
    And I create "/title1/title2" page with title "Some title2"
    And I create "/title1/title3" page with title "Some title3"
    And I follow "Some title"
    And I follow "Summary"
    And I should see "Subpages for page: Some title" within "body"
    And I should see "   Some title" within "body"
    And I should see "Some title1" within "body"
    And I should see "Some title2" within "body"
    Then I should see "Some title3" within "body"


  Scenario: User without rights wants to view subpages tree
    Given I am not logged in
    When I login as "johno"
    And I create "/" page
    And page "/" is viewable by "johno"
    And I create "/title1" page with title "Some title1"
    And page "/title1" is viewable by "johno"
    And I logout
    And I login as "majzunova"
    And I create "/title1/title2" page with title "Some title2"
    And page "/title1/title2" is viewable by "majzunova"
    And I follow "Summary"
    Then I should not see "Some title1" within "body"

  Scenario: User wants to go to page without slash
    When I create "/" page
    And I create "/nested" page with address in body
    Then I should see "Address: /nested/"
    
  