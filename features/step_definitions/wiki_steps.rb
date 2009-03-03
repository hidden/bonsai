When /^I login as "(.*)"$/ do |username|
  fill_in('username', :with => username)
  fill_in('password', :with => username)
  click_button('Log in')
end

Given /^that a "(.*) page with multiple revisions exist$/ do |page|
  user = User.create(:name => 'johno', :username => 'johno')
  page = Page.create!(:title => "main")
  page_part = PagePart.create!(:name => "body", :page => page, :current_page_part_revision_id => 0)
  revision_one = PagePartRevision.create!(:page_part => page_part, :user => user, :body => "This is first revision", :summary => "This is first summary")
  revision_two = PagePartRevision.create!(:page_part => page_part, :user => user, :body => "This is second revision", :summary => "This is second summary")
  page_part.current_page_part_revision = revision_two
  page_part.save!
end


