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
  fill_in('body', :with => 'Some content.')
  fill_in('summary', :with => 'A summary.')
  click_button('Create')
end

Given /^user "(.*)" exists$/ do |username|
  User.create(:username => username, :name => username)
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

Given /^that a "(.*) page with multiple revisions exist$/ do |page|
  user = User.create(:name => 'johno', :username => 'johno')
  page = Page.create!(:title => "main")
  page_part = page.page_parts.create(:name => "body", :current_page_part_revision_id => 0)
  page_part.page_part_revisions.create(:user => user, :body => "This is first revision", :summary => "This is first summary")
  page_part.current_page_part_revision = page_part.page_part_revisions.create(:page_part => page_part, :user => user, :body => "This is second revision", :summary => "This is second summary")
  page_part.save!
end



#vytvorenie novej skupiny
#when i create group nazov novej group
When /^I create "(.*)" group$/ do |group_name|
  click_link('Groups')
  click_link('New group')
  fill_in('group_name', :with => group_name)
  click_button('Create')
end


When /^I follow "(.*)" edit$/ do |group_name|
  
  click_link("Edit_#{Group.find_by_name(group_name).id}")
end

When /^I follow "(.*)" destroy$/ do |group_name|
  
  click_link("Destroy_#{Group.find_by_name(group_name).id}")
end

When /^I follow "(.*)" remove member$/ do |user_name|

  click_link("Remove_member_#{User.find_by_name(user_name).id}")
end

Given /^group "\/?(.*)\/?" is viewable by "(.*)"$/ do |url, group|
  page = Page.find_by_path(url.split("/"))
  page.add_viewer Group.find_by_name(group)
end

Given /^group "\/?(.*)\/?" is editable by "(.*)"$/ do |url, group|
  page = Page.find_by_path(url.split("/"))
  page.add_editor Group.find_by_name(group)
end