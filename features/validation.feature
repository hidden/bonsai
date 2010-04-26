Feature: Wiki
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
   
  Scenario: Check if new page is XHTML valid
   And I create "/" page
   Then this page is XHTML valid 
   
  Scenario: Check if edit page is XHTML valid
   And I follow "Edit"
   Then this page is XHTML valid
  
  Scenario: Check if history page is XHTML valid
   And I follow "history" 
   Then this page is XHTML valid
  
  Scenario: Check if revision page is XHTML valid
   When I follow "history"
   And I follow "Show page from revision 1"
   Then this page is XHTML valid
  
  Scenario: Check if registration page is XHTML valid
   When I am not logged in 
   Then this page is XHTML valid
   When I follow "Registration"
   Then this page is XHTML valid
   
  Scenario: Check if after invalid fulltext search page is XHMTL valid
   When I create "/" page with title "korenova stranka"
   And I go to the main page
   And indexes are updated
   And I search for "korstranka"
   Then this page is XHTML valid
    
  Scenario: Check if after fulltext search page is XHMTL valid
   When I create "/" page with title "korenova stranka"
   And I go to the main page
   And indexes are updated
   And I search for "korenova"
   Then this page is XHTML valid
   
    
   
   
   
   
   
    
