Feature: Wiki favorites

  Background:
    Given I am logged in

  @wip
  Scenario: User visits empty dashboard
    When I create "/" page with title "tot je fav"
    And I follow "dashboard"
    Then I should see "0"

  @wip
  Scenario: User adds and remove page to favorites
    When I create "/" page with title "tot je fav"
    And I follow "favorite"
    And I follow "dashboard"
    Then I should see "tot je fav"
    When I follow "Return to page"
    And I follow "favorite"
    And I follow "dashboard"
    Then I should not see "tot je fav"

  @wip
  Scenario: User adds and remove page to favorites (remove trough dashboard)
    When I create "/" page with title "tot je fav"
    And I follow "favorite"
    And I follow "dashboard"
    Then I should see "tot je fav"
    Then I follow "remove from favorites"
    Then I should not see "tot je fav"
    
