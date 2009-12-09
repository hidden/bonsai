Background:
  Given I am logged in
  
Scenario: User log in, set SK locale and should see slovak page
  When I create "/" page
  And I go to /users/save_locale?locale=sk
  Then I should see "Súbory"
  And I follow "Manažment"
  And I should see "Prístupové práva pre"
  Then I go to /users/save_locale?locale=en

Scenario: Anonymous user set language, after he/she returns, he/she should see wiki in selected language
  Given user "jozo" exists
  When I logout
  And I go to /users/save_locale?locale=en
  And I login as "jozo"
  And I create "/" page
  And I go to /users/save_locale?locale=sk
  Then I should see "Skupiny"
  When I go to /users/logout
  Then I should see "Login"
  And I should see "Password"
  When I login as "jozo"
  Then I should see "Skupiny"
  And I go to /users/save_locale?locale=en
