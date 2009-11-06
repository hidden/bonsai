When /^I login as "([^\"]*)"$/ do |username|
  fill_in('username', :with => username)
  fill_in('password', :with => username)
  click_button('Log in')
end


When /^I login as "([^"]*)" using password "([^"]*)"/ do |username, password|
  fill_in('username', :with => username)
  fill_in('password', :with => password)
  click_button('Log in')
end


When /^I logout$/ do
  click_link('Log out')
end

When /^I create "([^"]*)" page$/ do |url|
  visit url
  fill_in('title', :with => 'Some title')
  fill_in('body', :with => 'Some content.')
  fill_in('summary', :with => 'A summary.')
  click_button('Create')
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
  click_button('Create')
end

When /^I create "([^"]*)" page with title "([^"]*)" body "([^"]*)"$/ do |url, title, body|
  visit url
  fill_in('title', :with => title)
  fill_in('body', :with => body)
  fill_in('summary', :with => "summary")
  click_button('Create')
end


When /^I create "([^"]*)" page with title "([^"]*)" body "([^"]*)" and "([^"]*)" layout$/ do |url, title, body, my_layout|
  visit url
  fill_in('title', :with => title)
  fill_in('body', :with => body)
  fill_in('summary', :with => "summary")
  select(my_layout, :from => 'layout')
  click_button('Create')
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

When /^I compare revision "([^"]*)" with "([^"]*)"$/ do |first_revision, second_revision|
  choose(first_revision)          
  choose(second_revision)
  click_button('compare selected versions')
end

When /^I add "([^"]*)" page part with text "([^"]*)"$/ do |part_name, text|
  click_link('edit')
  fill_in('new_page_part_name', :with => part_name )
  fill_in('new_page_part_text', :with => text )
  click_button('Add new page part')
end


When /^I edit "([^"]*)" page part with text "([^"]*)"$/ do |part_name, new_name|
  click_link('edit')
  fill_in("page_part_name_#{part_name}", :with => new_name )
  click_button('Save')
end


When /^I delete "([^"]*)" page part$/ do |part_name|
  click_link('edit')
  check("is_deleted_#{part_name}")
  click_button('Save')
end

Given /^user "(.*)" exists$/ do |username|
  User.create(:username => username, :name => username)
end


Given /^that a "(.*) page with multiple revisions exist$/ do |page|
  user = User.create(:name => 'johno', :username => 'johno')
  page = Page.create!(:title => "main")
  page_part = page.page_parts.create(:name => "body", :current_page_part_revision_id => 0)
  page_part.page_part_revisions.create(:user => user, :body => "This is first revision", :summary => "This is first summary")
  page_part.current_page_part_revision = page_part.page_part_revisions.create(:page_part => page_part, :user => user, :body => "This is second revision", :summary => "This is second summary")
  page_part.save!
end


When /^I upload "(.*)" file$/ do |file_name|
  visit path_to('/')  
  click_link('edit')
  attach_file("uploaded_file_uploaded_data", File.join(Rails.root, 'features', 'fixtures', file_name))
  #attach_file(field, File.join(Rails.root, 'features', 'fixtures', path))
  click_button('Upload')
end










Then /^I must see "(.*)"$/ do |text|
  arr = arr.split(/ *& */);
  for item in arr
    regexp =  Regexp.new(item)
    response.should contain(regexp)
  end
end