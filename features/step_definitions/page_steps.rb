When /^I create "([^"]*)" page$/ do |url|
  visit url
  fill_in('title', :with => 'Some title')
  fill_in('body', :with => 'Some content.')
  fill_in('summary', :with => 'A summary.')
  click_button('Save')
end

#When /^I create "([^"]*)" page with file link$/ do |url|
#  visit url
#  fill_in('title', :with => 'Some title')
#  fill_in('body', :with => '[linka](subor.txt)')
#  fill_in('summary', :with => 'A summary.')
#  click_button('Create')
#end

When /^I create "([^"]*)" page with title "([^"]*)"$/ do |url, title|
  visit url
  fill_in('title', :with => title)
  fill_in('body', :with => 'Some content.')
  fill_in('summary', :with => 'A summary.')
  click_button('Save')
end

When /^I create "([^"]*)" page with title "([^"]*)" body "([^"]*)"$/ do |url, title, body|
  visit url
  fill_in('title', :with => title)
  fill_in('body', :with => body)
  fill_in('summary', :with => "summary")
  click_button('Save')
end


When /^I create "([^"]*)" page with title "([^"]*)" body "([^"]*)" and "([^"]*)" layout$/ do |url, title, body, my_layout|
  visit url
  fill_in('title', :with => title)
  fill_in('body', :with => body)
  fill_in('summary', :with => "summary")
  select(my_layout, :from => 'layout')
  click_button('Save')
end

When /^I edit "([^"]*)" page with title "([^"]*)"$/ do |url, title|
  visit path_to(url)
  click_link('edit')
  fill_in('title', :with => title)
  click_button('Save')
end

When /^I edit "([^"]*)" page with title "([^"]*)" body "([^"]*)"$/ do |url, title, body|
  visit path_to(url)
  click_link('edit')
  fill_in('title', :with => title)
  fill_in('parts[body]', :with => body)
  click_button('Save')
end

When /^I create "([^"]*)" page with title "([^"]*)" string body$/ do |url, title, body|
  visit url
  fill_in('title', :with => title)
  fill_in('body',:with => body)
  fill_in('summary', :with => "summary")
  click_button('Save')
end

When /^I create "([^"]*)" page with address in body$/ do |url|
  visit url
  fill_in('title', :with => 'Some title')
  fill_in('body',:with => 'Address: ' + request.env['PATH_INFO'])
  fill_in('summary', :with => "summary")
  click_button('Save')
end
