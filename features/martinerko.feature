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



#tento test predpoklada ze:
#1.tabulka skupin bude mat jedinecne id (Groups_table), ktore zatial NEMA!?
#2. link na delete bude mat taktiez jedinecne id (Destroy_MyNewGroup), ktore zatial NEMA!?
Scenario: User wants to delete group
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I follow "Groups"
    Then I should see "Groups Management"
    And I follow "New group"
    Then I should see "New group"
    And I fill in "group_name" with "MyNewGroup"
    And I press "Create"
    Then I should see "MyNewGroup" within "Groups_table"
    And I follow "Destroy_MyNewGroup"
    And I press "OK"
    Then I should not see "MyNewGroup" within "Groups_table"


#tento test predpoklada ze:
#1.tabulka skupin bude mat jedinecne id (Groups_memberstable), ktore zatial NEMA!?
#2. link na editovanie bude mat taktiez jedinecne id (Edit_MyNewGroup), ktore zatial NEMA!?
Scenario: User wants to add permisions within his group to another user
    Given user "TestUser" exists
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    Then I should see "Group was successfully created."
    And I follow "Edit_MyNewGroup"
    And I fill in "add_user_usernames" with "testuser"
    And I select "editor" from "add_user_type"
    And I press "Add"
    Then I should see "TestUser" within "Groups_memberstable"
    

#tento test predpoklada ze:
#1.tabulka skupin bude mat jedinecne id (Groups_memberstable), ktore zatial NEMA!?
#2. link na editovanie bude mat taktiez jedinecne id (Edit_MyNewGroup), ktore zatial NEMA!?
Scenario: User wants to delete another user from his group
    Given user "TestUser" exists
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    Then I should see "Group was successfully created."
    And I follow "Edit_MyNewGroup"
    And I fill in "add_user_usernames" with "TestUser"
    And I select "editor" from "add_user_type"
    And I press "Add"
    Then I should see "TestUser" within "Groups_memberstable"
    And I follow "Remove_member_testuser"
    Then I should not see "TestUser" within "Groups_memberstable"





#tento test predpoklada ze:
#1.tabulka skupin bude mat jedinecne id (Groups_memberstable), ktore zatial NEMA!?
#2. link na editovanie bude mat taktiez jedinecne id (Edit_MyNewGroup), ktore zatial NEMA!?
#3. link na delete bude mat taktiez jedinecne id (Destroy_MyNewGroup), ktore zatial NEMA!?
Scenario: User was given permission to manage group. He wants to manage group, we check if he has permission
    Given user "TestUser" exists
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    And I follow "Edit_MyNewGroup"
    And I fill in "add_user_usernames" with "TestUser"
    And I select "editor" from "add_user_type"
    And I press "Add"
    Then I logout
    And I login as "TestUser"
    And I follow "Groups"
    Then I should see "Edit_MyNewGroup" within "Groups_memberstable"
    And I should see "Destroy_MyNewGroup" within "Groups_memberstable"

#tento test predpoklada ze:
#1.tabulka skupin bude mat jedinecne id (Groups_memberstable), ktore zatial NEMA!?
#2. link na editovanie bude mat taktiez jedinecne id (Edit_MyNewGroup), ktore zatial NEMA!?
#3. link na delete bude mat taktiez jedinecne id (Destroy_MyNewGroup), ktore zatial NEMA!?
Scenario: User was not given permission to manage group. He wants to manage group, we check if he has permission
    Given user "TestUser" exists
    When I go to the main page
    And I login as "martinerko"
    And I create "/" page
    And I create "MyNewGroup" group
    And I follow "Edit_MyNewGroup"
    And I fill in "add_user_usernames" with "TestUser"
    And I select "editor" from "add_user_type"
    And I press "Add"
    Then I logout
    And I login as "TestUser"
    And I follow "Groups"
    Then I should not see "Edit_MyNewGroup" within "Groups_memberstable"
    And I should not see "Destroy_MyNewGroup" within "Groups_memberstable"



#RSS testy
#test predpoklada existenciu odkazu na Rss v menu
Scenario: check if RSS works properly
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I follow "Rss"
    Then I should see "Some title changes" within "feedTitleText"
    And I go to the main page
    And I follow "Edit"
    And I fill in "title" with "Some NEW title"
    And I press "Save"
    Then I should see "Page successfully updated."
    And I follow "Rss"
    Then I should see "Some NEW title changes" within "feedTitleText"



    