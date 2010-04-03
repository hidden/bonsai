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
    And I follow "PermissionsHistory"
    And I should see "crutch"
    And I add "matell" editor to "MyNewGroup2" group
    And I follow "PermissionsHistory"
    And I should see "matell"
    And I should not see "crutch"
