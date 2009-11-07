
When /^I add "([^"]*)" reader permission$/ do |user|
  visit path_to('/')
  click_link('Manage')
  fill_in('add_group', :with => user)
  check('can_view')
  click_button('Set')
end


When /^I add "([^"]*)" editor permission$/ do |user|
  visit path_to('/')
  click_link('Manage')
  fill_in('add_group', :with => user)
  check('can_edit')
  click_button('Set')
end

When /^I add "([^"]*)" manager permission$/ do |user|
  visit path_to('/')
  click_link('Manage')
  fill_in('add_group', :with => user)
  check('can_manage')
  click_button('Set')
end

Given /^page "\/?(.*)\/?" is viewable by "(.*)"$/ do |url, group|
  page = Page.find_by_path(url.split("/"))
  page.add_viewer Group.find_by_name(group)
end

Given /^page "\/?(.*)\/?" is editable by "(.*)"$/ do |url, group|
  page = Page.find_by_path(url.split("/"))
  page.add_editor Group.find_by_name(group)
end

Given /^page "\/?(.*)\/?" is manageable by "(.*)"$/ do |url, group|
  page = Page.find_by_path(url.split("/"))
  page.add_manager Group.find_by_name(group)
end