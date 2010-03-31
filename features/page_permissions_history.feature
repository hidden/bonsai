Feature: PagePermissionsHistory

Scenario: User creates page, adds some permissions and should see this in history
  Given user "matell" exists
  And user "crutch" exists
  When I go to the main page
  And I login as "johno"
  And I create "/" page
  And I add "matell" reader permission
  And I add "crutch" editor permission
  And I follow "Edit"
  And I follow "PermissionsHistory"
  And I should see "johno"
  And I should see "matell"
  And I should see "crutch"

Scenario: User creates page, adds some permissions, then deletes group and this group should not be seen in history
  When I go to the main page
  And I login as "johno"
  When I create "/" page
  And I create "NewGroup" group
  And I add "NewGroup" reader permission
  And I follow "Edit"
  And I follow "PermissionsHistory"
  Then I should see "NewGroup"
  When I delete "NewGroup" group
  And I go to the main page
  And I follow "Edit"
  And I follow "PermissionsHistory"
  Then I should not see "NewGroup"
