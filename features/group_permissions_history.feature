Feature: GroupPermissionsHistory

  Background:
    Given I am logged in

  Scenario: User wants to see history of permissions of group
    Given user "crutch" exists
    Given user "matell" exists
    When I create "/" page
    And I create "MyNewGroup" group
    And I go to the main page
    And I create "MyNewGroup2" group
    And I add "crutch" editor to "MyNewGroup" group
    And I visit group "MyNewGroup" management
    And I follow "PermissionsHistory"
    And I should see "crutch"
    And I add "matell" editor to "MyNewGroup2" group
    And I visit group "MyNewGroup2" management
    And I follow "PermissionsHistory"
    And I should see "matell"
    And I should not see "crutch"
  
  Scenario: User wants to see history of permissions of group in dashboard
    Given user "crutch" exists
    When I logout
    And I go to the main page
    And I login as "matell"
    And I create "/" page
    And I create "MyNewGroup" group
    And I add "crutch" editor to "MyNewGroup" group
    Then I logout
    When I login as "crutch"
    And I follow "dashboard"
    #And I follow "Show older changes"
    And I should see "matell sets you as Editor for group MyNewGroup"
