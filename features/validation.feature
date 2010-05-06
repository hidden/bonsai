Feature: Validation
  In order to see the same look of wiki on any browser
  A wiki
  Should be XHTML valid

  Background:
    Given I am logged in
    And that a "main" page with multiple revisions exist
    And I go to the main page

  Scenario: Check if main page is XHTML valid
   When I go to the main page
   Then this page is XHTML valid

  Scenario: Check if groups page is XHTML valid
   When I follow "Groups"
   Then this page is XHTML valid
   When I follow "New group"
   Then this page is XHTML valid
   When I go to the main page
   And I create "New group" group
   And I go to the main page
   And I follow "Groups"
   And I follow "Edit"
   Then this page is XHTML valid

 Scenario: Check if administration is XHTML valid
   When I load admin group with id "3"
    And I create "Admins" group
   Then I should see "Group was successfully created."
    And I go to the main page
    When I follow "Administration"
    Then this page is XHTML valid
    Then I load admin group with id "0"
   
 Scenario: Check if edit page is XHTML valid
   When I follow "Edit"
   Then this page is XHTML valid

 Scenario: Check if history page is XHTML valid
   When I follow "History"
   Then this page is XHTML valid

 Scenario: Check if files page is XHTML valid
   When I follow "Files" 
   Then this page is XHTML valid
  
  Scenario: Check if revision page is XHTML valid
   When I follow "History"
   And I follow "Show page from revision 1"
   Then this page is XHTML valid

  Scenario: Check if dashboard page is XHTML valid
   When I follow "dashboard"
   Then this page is XHTML valid
  
  Scenario: Check if registration page is XHTML valid
   When the user registration is enabled    
   When I am not logged in 
   Then this page is XHTML valid
   When I follow "Registration"
   Then this page is XHTML valid
   
  
   
    
   
   
   
   
   
    
