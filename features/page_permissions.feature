Feature: Secure wiki
  In order to have a secure wiki
  A user
  Should be able to set permissions for viewing, editing and managing pages.
  
  Scenario: Wiki page viewable by one user
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And page "/" is viewable by "johno"
    When I logout
    When I login as "johno"
    Then I should see "Some content."

  Scenario: Manager can edit page permissions and page
    Given I am logged in
    And I create "/" page
    And I should see "Edit"
    And I follow "Edit"
    Then I should see "Permissions"

  Scenario: Editor cannot manage page permissions
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I logout
    And I login as "crutch"
    And page "/" is editable by "crutch"
    When I go to the main page
    And I should see "Edit"
    And I follow "Edit"
    Then I should not see "Permissions"

  Scenario: Viewer can only view page
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And page "/" is editable by "johno"
    And I logout
    And I login as "crutch"
    And I should not see "Edit"

  Scenario: Anonymous cannot see a restricted page
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And page "/" is viewable by "johno"
    And I logout
    Then I should see "Permission denied."
    Then I should not see "History"
    Then I should not see "Edit"

  Scenario: Anonymous can see a public page
     Given I am logged in
     And I create "/" page
     And I logout
     Then I should not see "Permission denied."
     Then I should see "History"

  Scenario: Manager adds an editor to a public page
    Given user "matell" exists
    And user "crutch" exists
    And I am logged in
    When I create "/" page
    And I add "matell,johno" editor permission
    And I logout
    And I login as "crutch"
    Then I should not see "Edit"
    And I logout
    And I login as "matell"
    And I should see "Edit"

  Scenario: Manager adds another manager to a public page
    Given user "matell" exists
    And user "crutch" exists
    And I am logged in
    When I create "/" page
    And I add "matell" manager permission
    And I logout
    And I login as "crutch"
    Then I should not see "Edit"
    And I logout
    And I login as "matell"
    And I follow "Edit"
    And I should see "Permissions"

  Scenario: Manager adds a viewer to a public page, so it is no longer public
    Given user "matell" exists
    And user "crutch" exists
    And I am logged in
    When I create "/" page
    #And I follow "Manage"
    #And I fill in "add_group" with "matell"
    #And I select "matell" from "groups_id"
    #And I check "can_view"
    And I add "matell" reader permission
    And I go to the main page
    Then I should not see "Permission denied."
    And I logout
    And I login as "matell"
    Then I should not see "Permission denied."
    And I logout
    And I login as "crutch"
    Then I should see "Permission denied."
    

  Scenario: Manager adds an editor to a non-public page
    Given user "matell" exists
    And user "crutch" exists
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And page "/" is viewable by "johno"
    And page "/" is editable by "johno"
    And I add "matell" editor permission
    And I logout
    And I login as "matell"
    Then I should not see "Permission denied."
    And I should see "Edit"
    And I logout
    And I login as "crutch"
    Then I should see "Permission denied."

  Scenario: Manager adds another manager to a non-public page
    Given user "matell" exists
    And user "crutch" exists
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And page "/" is viewable by "johno"
    And page "/" is editable by "johno"
    And I add "matell" manager permission
    And I logout
    And I login as "matell"
    Then I should not see "Permission denied."
    And I should see "Edit"
    And I follow "Edit"
    And I should see "Permissions"
    And I logout
    And I login as "crutch"
    Then I should see "Permission denied."

  Scenario: Manager inherits permissions to view a non-public page
    Given user "matell" exists
    And user "crutch" exists
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I logout
    And I login as "matell"
    And I create "/test/" page
    And page "/test/" is viewable by "matell"
    And page "/test/" is editable by "matell"
    And I logout
    And I login as "johno"
    And I go to the test page
    Then I should not see "Permission denied"
    And I should see "Edit"
    And I follow "Edit"
    And I should see "Permissions"
    And I logout
    And I login as "crutch"
    And I go to the test page
    Then I should see "Permission denied"
    And I should not see "Edit"
    

  @wip
  Scenario: Editor inherits permissions to view a non-public page
    Given user "matell" exists
    And user "crutch" exists
    And user "bielikova" exists
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And page "/" is editable by "matell"
    And I create "/test/" page
    And page "/test/" is viewable by "crutch"
    And I logout
    And I login as "matell"
    And I go to the test page
    Then I should not see "Permission denied"
    And I should see "Edit"
    And I should not see "Permissions"
    And I logout
    And I login as "bielikova"
    And I go to /test/
    Then I should see "Permission denied"
    And I should not see "Edit"
    And I should not see "Manage"

  Scenario: User creates group with 2 users, in autocomplete for groups he/she should see name of group and users in brackets
    Given user "jozo" exists
    Given user "fero" exists
    When I go to the main page
    And I login as "jano"
    And I create "/" page
    And I create "TestGroup" group
    And I add "jozo" viewer to "TestGroup" group
    And I add "fero" viewer to "TestGroup" group
    And I go to /w/groups/autocomplete_for_groups?infix=Test
    And I should see "TestGroup"
    And I should see "jano"
    And I should see "jozo"
    And I should see "fero"

  Scenario: User creates group with 2 users, in autocomplete for groups he/she should see name of group and users in brackets
    Given user "jozo" exists
    Given user "fero" exists
    When I go to the main page
    And I login as "jano"
    And I create "/" page
    And I create "TestGroup" group
    And I add "jozo" viewer to "TestGroup" group
    And I add "fero" viewer to "TestGroup" group
    And I go to /w/groups/autocomplete_for_groups?infix=jan
    And I should see "TestGroup"

  @wip  
  Scenario: User creates group, addd permissions for this group, then erases this group and in page management he should not see this group
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I create "MyNewGroup" group    
    And I add "MyNewGroup" reader permission
    And I follow "Edit"
    And I should see "MyNewGroup"
    When I delete "MyNewGroup" group
    And I go to the main page
    And I follow "Edit"
    Then I should not see "MyNewGroup"
  Scenario: User create page with many managers and should not be allowed to remove all of them (there must be always at least 1 manager)
    Given user "jozo" exists
    Given user "fero" exists
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I add "jozo" manager permission
    And I add "fero" manager permission
    And I follow "Edit"
    And I remove "fero" manager permission
    And I remove "jozo" manager permission
    And I remove "johno" manager permission
    And I follow "Edit"
    And I should see "Permissions"
    And I logout
    And I login as "fero"
    When I follow "Edit"
    Then I should not see "Permissions"
    And I logout
    And I login as "jozo"
    When I follow "Edit"
    Then I should not see "Permissions"
