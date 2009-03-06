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
    And I go to the main page
    Then I should see "Permission denied."
    When I login as "crutch"
    Then I should see "Permission denied."
    When I logout
    When I login as "johno"
    Then I should see "Some content."

Scenario: Manager can edit page permissions
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    Then I should see "Manage"

Scenario: Manager can edit page

Scenario: Editor can edit page

Scenario: Editor cannot manage page permissions

Scenario: Viewer can only see page
    When I go to the main page
    And I login as "johno"
    And I create "/" page
    And I logout
    And I login as "crutch"
    Then I should not see "Manage"
    And I should not see "Edit"

Scenario: Anonymous cannot see a restricted page

Scenario: Anonymous can see a public page