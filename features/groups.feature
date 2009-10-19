Feature: Wiki
    In order to share content on wiki
    A user
    Should be able to create and manage wiki groups


Scenario: User wants to create new group
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I follow "Groups"
    Then I should see "Groups Management"
    And I follow "New group"
    Then I should see "New group"
    And I fill in "group_name" with "MyNewGroup"
    And I press "Create"
    Then I should see "Group was successfully created."
    

Scenario: User wants to edit name of group
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I follow "Groups"
    Then I should see "Groups Management"
    And I follow "New group"
    Then I should see "New group"
    And I fill in "group_name" with "MyNewGroup"
    And I press "Create"
    Then I should see "Group was successfully created."
    And I fill in "group_name" with "My edited group"
    And I press "Update"
    Then I should see "Group was successfully updated."


Scenario: User wants to edit name of group, just after he/she creates new group
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    Then I should see "Group was successfully created."



#tento test predpoklada neskonci pretoze nevieme testovat javasciptove okna:
Scenario: User wants to delete group
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    And I follow "Back"
    Then I should see "Groups Management"
    When I follow "Destroy_MyNewGroup"
    #And I press "OK"
    #Then I should not see "MyNewGroup" within "Groups_table"


Scenario: User wants to add permisions within his group to another user
    Given user "TestUser" exists
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    Then I should see "Group was successfully created."
    When I follow "Back"
    And I follow "Edit_MyNewGroup"
    And I fill in "add_user_usernames" with "TestUser"
    And I select "editor" from "add_user_type"
    And I press "Add"
    Then I should see "TestUser"
    


Scenario: User wants to delete another user from his group
    Given user "TestUser" exists
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    Then I should see "Group was successfully created."
    When I follow "Back"
    And I follow "Edit_MyNewGroup"
    And I fill in "add_user_usernames" with "TestUser"
    And I select "editor" from "add_user_type"
    And I press "Add"
    Then I should see "TestUser"
    And I follow "Remove_member_TestUser"
    Then I should not see "TestUser"





Scenario: User was given permission to manage group. He wants to manage group, we check if he has permission
    Given user "matell" exists
    Given user "crutch" exists
    When I go to the main page
    And I login as "matell"
    And I create "/" page
    And I create "MyNewGroup" group
    And I fill in "add_user_usernames" with "crutch"
    And I select "editor" from "add_user_type"
    And I press "Add"
    And I follow "Back"
    When I logout
    Then I should see "Logout successfull."
    When I login as "crutch"
    And I follow "Groups"
    Then I should see "Groups Management"
    When I follow "Edit_MyNewGroup"
    Then I should see "Group MyNewGroup"
    When I follow "Back"
    And I follow "Destroy_MyNewGroup"
    #And I press "OK"
    #Then I should not see "MyNewGroup" within "Groups_table"

Scenario: User was not given permission to manage group. He wants to manage group, we check if he has permission
    Given user "matell" exists
    Given user "crutch" exists
    When I go to the main page
    And I login as "matell"
    And I create "/" page
    And I create "MyNewGroup" group
    And I fill in "add_user_usernames" with "crutch"
    And I select "viewer" from "add_user_type"
    And I press "Add"
    And I follow "Back"
    When I logout
    Then I should see "Logout successfull."
    When I login as "crutch"
    And I follow "Groups"
    Then I should see "Groups Management"
    And I should not see "Edit"
    And I should not see "Destroy"







    