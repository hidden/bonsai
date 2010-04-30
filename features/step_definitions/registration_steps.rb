When /^the user registration is ([^"]*)$/ do |option|
  case option
    when "disabled"
      APP_CONFIG['allow_user_registration'] = false
    when "enabled"
      APP_CONFIG['allow_user_registration'] = true
  end
end

When /^I make registration with login "([^\"]*)", name "([^\"]*)", password "([^\"]*)" and password confrimation "([^\"]*)"$/ do |username, name, password, password_confirmation|
  fill_in('Username', :with => username)
  fill_in('Name', :with => name)
  fill_in('Password', :with => password)
  fill_in('Password confirmation', :with => password_confirmation)
  click_button('Submit registration')
end