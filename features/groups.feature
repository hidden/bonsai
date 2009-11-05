Feature: Wiki
  In order to share content on wiki
  A user
  Should be able to create and manage wiki groups


  Scenario: User wants to create new group
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "New group" group
    Then I should see "Group was successfully created."


  Scenario: User wants to change name of group
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "Newgroup" group
    And I change "Newgroup" group name to "MyNewNameOfgroup"
    Then I should see "Group was successfully updated."
    And I should see "MyNewNameOfgroup"

  Scenario: User wants to change name of group, just after he/she creates new group
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    And I fill in "group_name" with "MyNewNameOfgroup"
    And I press "Update"
    Then I should see "Group was successfully updated."
    
  Scenario: User wants to delete group
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    And I follow "Back"
    Then I should see "Groups Management"
    Then I should see "MyNewGroup"
    When I delete "MyNewGroup" group
    Then I should not see "MyNewGroup"
    When I go to the main page
    And I follow "Groups"
    Then I should not see "MyNewGroup"



  Scenario: User wants to add permisions within his group to another user
    Given user "TestUser" exists
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    And I add "TestUser" editor to "MyNewGroup" group
    Then I should see "TestUser"


  Scenario: User wants to remove another user from his group
    Given user "TestUser" exists
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    And I add "TestUser" editor to "MyNewGroup" group
    Then I should see "TestUser"
    When I remove "TestUser" member from "MyNewGroup" group
    Then I should not see "TestUser"


  Scenario: User was given permission to manage group. He wants to manage group, we check if he has permission
    Given user "matell" exists
    Given user "crutch" exists
    When I go to the main page
    And I login as "matell"
    And I create "/" page
    And I create "MyNewGroup" group
    And I add "crutch" editor to "MyNewGroup" group
    When I logout
    And I login as "crutch"
    And I follow "Groups"
    Then I should see "Groups Management"
    And I should see "Edit"
    And I should see "Destroy"
    When I follow "MyNewGroup" edit
    Then I should see "Group MyNewGroup"

  Scenario: User was not given permission to manage group. He wants to manage group, we check if he has permission
    Given user "matell" exists
    Given user "crutch" exists
    When I go to the main page
    And I login as "matell"
    And I create "/" page
    And I create "MyNewGroup" group
    And I add "crutch" viewer to "MyNewGroup" group
    When I logout
    And I login as "crutch"
    And I follow "Groups"
    Then I should see "Groups Management"
    And I should not see "Edit"
    And I should not see "Destroy"

  Scenario: Return to main page
    When I go to the main page
    And I login as "bio"
    And I create "/" page with title "Root title"
    And I follow "Groups"
    Then I should see "Groups Management"
    When I follow "Return to page"
    Then I should see "Root title"

  Scenario: Return to nested page
    When I go to the main page
    And I login as "bio"
    And I create "/" page with title "Root title"
    And I create "/nested_page/" page with title "Nested title"
    And I go to /nested_page/
    And I follow "Groups"
    Then I should see "Groups Management"
    When I follow "New group"
    And I follow "Return to page"
    Then I should see "Nested title"