Background:
  Given I am logged in
  
Scenario: User log in, set SK locale and should see slovak page
  When I create "/" page
  And I set locale to sk
  And I follow "Files"
  Then I should see "Súbory"
  And I follow "Manažment"
  When I should see "Prístupové práva pre"
