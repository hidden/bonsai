require 'thinking_sphinx/test'
ThinkingSphinx::Test.init

When 'indexes are updated' do
  # Update all indexes
  ThinkingSphinx::Test.index
  sleep(0.25) # Wait for Sphinx to catch up
end


When /^I search for "([^"]*)"$/ do |text|
  fill_in('search_text', :with => text)
  click_button('Search')
end