Feature: Wiki
  In order to see the same look of wiki on any browser
  A wiki
  Should be XHTML valid

  Background:
    #Given I am logged in

  @wip
  Scenario: Check if all pages are valid
   When I go to the main page
   And I am logged in
   Then this page is XHTML valid
    
