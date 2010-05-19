Feature: Wiki pages
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

  Scenario: User wants to go to page without slash
    When I create "/" page
    And I create "/nested" page with address in body
    Then I should see "Address: /nested/"

  Scenario: User wants to see a preview of page
    When I create "/" page with title "Title" body "Hello universe."
    And I edit "body" page part with text "Changed body" without saving
    And I press "Preview"
    Then I should see "This is preview"
    And I should see "Changed body"
    And I should not see "Hello universe."
    When I go to the main page
    Then I should see "Hello universe."
    And I should not see "Changed body"

  Scenario: User wants to see a preview of page
    When I create "/" page with title "Title" body "Hello universe." and "PeWe Layout" layout without saving
    And I press "Preview"
    Then I should see "This is preview"
    And I should see "Hello universe."
    When I go to /
    Then I should see "Page does not exists. Do you want to create it?"
    And I should not see "Hello universe."


  Scenario: User wants to add new page which don't exist
    When I create "/" page
    And I go to the main page
    And I follow "New page"
    And I fill in "add_page[new_page]" with "neo"
    And I press "Create"
    Then I should see "Page does not exists. Do you want to create it?"

  Scenario: User wants to add new page which exist
    When I create "/" page
    And I create "neo" page
    And I go to the main page
    And I follow "New page"
    And I fill in "add_page[new_page]" with "neo"
    And I press "Create"
    Then I should see "This page exists"
     
  Scenario: User wants to show help for maruku syntax when creating new page
    When I create "/" page with title "Title" body "Hello universe." and "PeWe Layout" layout without saving
    And I follow "Syntax help"
    Then I should see "Paragraphs"

  Scenario: User wants to show help for maruku syntax when editing page
    When I create "/" page with title "Hello world" body "Hello universe"
    And I follow "Edit"
    And I follow "Syntax help"
    Then I should see "Paragraphs"

  Scenario: User creates a page with inherit layout and change layout
    When I create "/" page
    And I create "/inherited" page with title "Inherit page" body "Inherit page body!" and "Inherited (Default Layout)" layout
    And I go to the main page
    And I follow "Edit"
    And I select "PeWe Layout" from "layout"
    And I press "Save"
    And I go to /inherited
    And I follow "Edit"
    And I should see "Inherited (PeWe Layout)"
    Then "" should be selected for "layout"

  Scenario: User creates a page with non inherit layout and change layout
    When I create "/" page
    And I create "/inherited" page with title "Inherit page" body "Inherit page body!" and "PeWe Layout" layout
    And I go to /inherited
    And I follow "Edit"
    And "PeWe Layout" should be selected for "layout"
    Then I should not see "Inherited (PeWe Layout)"
  