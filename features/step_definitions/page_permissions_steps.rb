
When /^I add "([^"]*)" reader permission$/ do |user|
  visit path_to('/')
  click_link('Edit')
  fill_in('add_group', :with => user)
  select('Viewer', :from => 'group_role_type')
  click_button('Save')
end


When /^I add "([^"]*)" editor permission$/ do |user|
  visit path_to('/')
  click_link('Edit')
  fill_in('add_group', :with => user)
  select('Editor', :from => 'group_role_type')
  click_button('Save')
end

When /^I add "([^"]*)" manager permission$/ do |user|
  visit path_to('/')
  click_link('Edit')
  fill_in('add_group', :with => user)
  select('Manager', :from => 'group_role_type')
  click_button('Save')
end

When /^I remove "([^"]*)" manager permission$/ do |user|
  visit path_to('/')
  click_link('Edit')
  select('Editor', :from => user + '_select')
  click_button('Save')
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
