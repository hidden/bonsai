Feature: Wiki favorites

  Background:
    Given I am logged in

  Scenario: User visits empty dashboard
    When I create "/" page with title "tot je fav"
    And I follow "dashboard"
    Then I should see "0"

  Scenario: User adds and remove page to favorites
    When I create "/" page with title "tot je fav"
    And I follow "favorite"
    And I follow "dashboard"
    Then I should see "tot je fav"
    When I follow "Return to page"
    And I follow "favorite"
    And I follow "dashboard"
    Then I should not see "tot je fav"

  Scenario: User adds and remove page to favorites (remove trough dashboard)
    When I create "/" page with title "tot je fav"
    And I follow "favorite"
    And I follow "dashboard"
    Then I should see "tot je fav"
    Then I follow "remove from favorites"
    Then I should not see "tot je fav"

  Scenario: User adds and multiple pages to favorites
    When I create "/" page with title "tot je root"
    And I follow "favorite"
    And I create "/nested/" page with title "tot je nested"
    And I follow "favorite"
    And I follow "dashboard"
    Then I should see "tot je root"
    And I should see "tot je nested"
    And I should see "2"
