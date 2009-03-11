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
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    Then I should see "Manage"
    And I should see "Edit"

Scenario: Editor cannot manage page permissions
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I logout
    And I login as "crutch"
    And page "/" is editable by "crutch"
    When I go to the main page
    Then I should not see "Manage"
    And I should see "Edit"

Scenario: Viewer can only view page
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And page "/" is editable by "johno"
    And I logout
    And I login as "crutch"
    Then I should not see "Manage"
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
    Then I should not see "Manage"

Scenario: Anonymous can see a public page
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I logout
    Then I should not see "Permission denied."
    Then I should see "History"

Scenario: Manager adds an editor to a public page
    Given user "johno" exists
    Given user "matell" exists
    Given user "crutch" exists
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I follow "Manage"
    And I select "johno" from "groups_id"
    And I select "matell" from "groups_id"
    And I check "can_edit"
    And I press "Set"
    And I logout
    And I login as "crutch"
    Then I should not see "Edit"
    And I logout
    And I login as "matell"
    And I should see "Edit"


Scenario: Manager adds another manager to a public page
    Given user "johno" exists
    Given user "matell" exists
    Given user "crutch" exists
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I follow "Manage"
    And I select "matell" from "groups_id"
    And I check "can_manage"
    And I press "Set"
    And I logout
    And I login as "crutch"
    Then I should not see "Manage"
    And I logout
    And I login as "matell"
    And I should see "Manage"

Scenario: Manager adds a viewer to a public page, so it is no longer public
    Given user "johno" exists
    Given user "matell" exists
    Given user "crutch" exists
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I follow "Manage"
    And I select "matell" from "groups_id"
    And I check "can_view"
    And I press "Set"
    And I go to the main page
    Then I should not see "Permission denied."
    And I logout
    And I login as "matell"
    Then I should not see "Permission denied."
    And I logout
    And I login as "crutch"
    Then I should see "Permission denied."

Scenario: Manager adds an editor to a non-public page
    Given user "johno" exists
    Given user "matell" exists
    Given user "crutch" exists
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And page "/" is viewable by "johno"
    And page "/" is editable by "johno"
    And I follow "Manage"
    And I select "matell" from "groups_id"
    And I check "can_edit"
    And I press "Set"
    And I logout
    And I login as "matell"
    Then I should not see "Permission denied."
    And I should see "edit"
    And I logout
    And I login as "crutch"
    Then I should see "Permission denied."

Scenario: Manager adds another manager to a non-public page
    Given user "johno" exists
    Given user "matell" exists
    Given user "crutch" exists
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And page "/" is viewable by "johno"
    And page "/" is editable by "johno"
    And I follow "Manage"
    And I select "matell" from "groups_id"
    And I check "can_manage"
    And I press "Set"
    And I logout
    And I login as "matell"
    Then I should not see "Permission denied."
    And I should see "edit"
    And I should see "manage"
    And I logout
    And I login as "crutch"
    Then I should see "Permission denied."
