Feature: Admin page

 Background:
    Given I am logged in
    Then I load admin group

 Scenario: Admin control passed
   When I create "/" page
    And I create "Admins" group
   Then I should see "Group was successfully created."
    And I go to the main page
    And I follow "Administration"
   Then I should see "Administration"

 Scenario: Admin control dont passed
    When I create "/" page
    And I go to the main page
   Then I should not see "Administration"

 Scenario: Search user
    When I create "/" page
    And I create "Admins" group
   Then I should see "Group was successfully created."
    And I go to the main page
    And I follow "Administration"
    And I fill in "add_user[usernames]" with "testuser"
    And I press "user_search"
   Then I should not see "testuser active"

 Scenario:
   Then I load admin group with id "0"
   


