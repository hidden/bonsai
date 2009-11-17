Scenario: User log in, set SK locale and should see slovak page
  When I go to the main page
  And I login as "martinerko"
  And I create "/" page
  When I set locale to sk
  And I follow "Files"
  Then I should see "Súbory"
  And I follow "Manažment"
  Then I should see "Prístupové práva pre"