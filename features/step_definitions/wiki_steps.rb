When /^I login as "(.*)"$/ do |username|
  fill_in('username', :with => username)
  fill_in('password', :with => username)
  click_button('Log in')
end

When /^I logout$/ do
  click_link('Log out')
end

When /^I create "(.*)" page$/ do |url|
  visit url
  fill_in('title', :with => 'Some title')
  fill_in('body', :with => 'Some contents.')
  click_button('Create')
end


Given /^user "(.*)" exists$/ do |username|
  User.create(:username => username, :name => username)
end

Given /^page "(.*)" is viewable by "(.*)"$/ do |path, group|
  page = Page.find_by_path(path.split('/'))
  page.add_viewer Group.find_by_name(group)
end