When /^\/?(.*)\/? changes page part "([^"]*)" at "([^"]*)" to "([^"]*)"$/ do |username, part_name, url, content|
  page = Page.find_by_path(url.split("/"))
  page_part = page.page_parts.find(:first, :conditions => {:name => part_name})
  user = User.find_or_create_by_username(:username => username, :name => username)
  revision = page_part.page_part_revisions.create(:user => user, :body => content)
  page_part.current_page_part_revision = revision
  page_part.save
end
