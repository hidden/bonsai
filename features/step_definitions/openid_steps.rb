Given /OpenID is used/ do
  APP_CONFIG['authentication_method'] = 'openid'
end

When /^I log in as "([^\"]*)" using OpenID$/ do |openid|
  fill_in('openid_identifier', :with => openid)
  click_button('Log in')
end