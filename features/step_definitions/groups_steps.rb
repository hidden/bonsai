Given /^group "(.*)" exists$/ do |group|
  Group.create(:name => group)
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


When /^I create "(.*)" group$/ do |group_name|
  click_link('Groups')
  click_link('New group')
  fill_in('group_name', :with => group_name)
  click_button('Create')
end

When /^I delete "(.*)" group$/ do |group_name|
  visit path_to('/')
  click_link('Groups')
  click_link("Destroy_#{Group.find_by_name(group_name).id}")
end

When /^I change "(.*)" group name to "(.*)"$/ do |group, new_group_name|
  visit path_to('/')
  click_link('Groups')
  click_link("Edit_#{Group.find_by_name(group).id}")
  fill_in('group_name', :with => new_group_name)
  click_button('Update')
end

When /^I add "(.*)" editor to "(.*)" group$/ do |user, group|
  visit path_to('/')
  click_link('Groups')
  click_link("Edit_#{Group.find_by_name(group).id}")
  fill_in('add_user_usernames', :with => user)
  select('Editor', :from => 'add_user_type')
  click_button('Update')
end


When /^I add "(.*)" viewer to "(.*)" group$/ do |user, group|
  visit path_to('/')
  click_link('Groups')
  click_link("Edit_#{Group.find_by_name(group).id}")
  fill_in('add_user_usernames', :with => user)
  select('Viewer', :from => 'add_user_type')
  click_button('Update')
end

When /^I remove "(.*)" member from "(.*)" group$/ do |user, group|
  visit path_to('/')
  click_link('Groups')
  click_link("Edit_#{Group.find_by_name(group).id}")
  click_link("Remove_member_#{User.find_by_name(user).id}")
end

When /^I change "(.*)" to viewer in "(.*)" group$/ do |user, group|
  visit path_to('/')
  click_link('Groups')
  click_link("Edit_#{Group.find_by_name(group).id}")
  select('Viewer', :from => user + '_select')
  click_button('Update')
end

