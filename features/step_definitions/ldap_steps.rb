Given /^LDAP is used$/ do
  APP_CONFIG['authentication_method'] = 'ldap'
end

When /^I login$/ do
  Given 'LDAP is used'
  When 'I go to the main page'
  fill_in('username', :with => 'user')
  fill_in('password', :with => 'user')
  click_button('Log in')
end

When /^I login as "([^\"]*)"$/ do |username|
  Given 'LDAP is used'
  When 'I go to the main page'
  fill_in('username', :with => username)
  fill_in('password', :with => username)
  click_button('Log in')
end


When /^I login as "([^"]*)" using password "([^"]*)"/ do |username, password|
  Given 'LDAP is used'
  When 'I go to the main page'
  fill_in('username', :with => username)
  fill_in('password', :with => password)
  click_button('Log in')
end

When /^I logout$/ do
  click_link('Log out')
end


Given /^I am logged in$/ do
  APP_CONFIG['authentication_method'] = 'ldap' if !ENV["OPENID"]
  APP_CONFIG['authentication_method'] = 'openid' if ENV["OPENID"]
  When 'I go to the main page'
  And 'I login as "testuser"' if !ENV["OPENID"]
  And 'I login as "http://testuser.myopenid.com" using OpenID' if ENV["OPENID"]
end

Given /^I am not logged in$/ do
  if session[:user_id] != nil
    When 'I go to the main page'
    And 'I logout'
  end
end


