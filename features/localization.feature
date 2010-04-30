Background:
  Given I am logged in
  
Scenario: User log in, set SK locale and should see slovak page
  When I create "/" page
  And I follow "SK"
  Then I should see "Súbory"
  And I follow "Editovať"
  And I should see "Prístupové práva"
  Then I follow "EN"

#TODO toto je nejaky divny test, ktory funguje len vdaka zamene textu a linku odkazu na prihlasovanie 
@wip
Scenario: Anonymous user set language, after he/she returns, he/she should see wiki in selected language
  Given user "jozo" exists
  When I logout
  And I login as "jozo"
  And I create "/" page
  And I follow "SK"
  Then I should see "Skupiny"
  When I go to /users/logout
  Then I should see "Login"
  And I should see "Password"
  When I login as "jozo"
  Then I should see "Skupiny"
  And I follow "EN"

Scenario: Anonymous user set language in his browser to unsupported language (e.g. Canadian Français), then user should get page in default locale
  When I logout
  And I set locale to "fr-CA"
  And I go to the main page
  And I should see "Permission denied"
