Feature: Secure wiki
    In order to have
    A user
    Should be able to create and manage wiki pages

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

Scenario: Anonymous can see a public page
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I logout
    Then I should not see "Permission denied."