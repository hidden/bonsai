When /^I compare revision "([^"]*)" with "([^"]*)"$/ do |first_revision, second_revision|
  choose(first_revision)
  choose(second_revision)
  click_button('compare selected versions')
end

Given /^that a "(.*) page with multiple revisions exist$/ do |page|
  user = User.create(:name => 'johno', :username => 'johno')
  page = Page.create!(:title => "main")
  page_part = page.page_parts.create(:name => "body", :current_page_part_revision_id => 0)
  page_part.page_part_revisions.create(:user => user, :body => "This is first revision", :summary => "This is first summary")
  page_part.current_page_part_revision = page_part.page_part_revisions.create(:page_part => page_part, :user => user, :body => "This is second revision", :summary => "This is second summary")
  page_part.save!
end
