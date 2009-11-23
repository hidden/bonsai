Given /^user "(.*)" exists$/ do |username|
  User.create(:username => username, :name => username)
end

Then /^I must see "(.*)"$/ do |text|
  arr = arr.split(/ *& */);
  for item in arr
    regexp =  Regexp.new(item)
    response.should contain(regexp)
  end
end

Then /^I should see a link to "([^\"]*)" with text "([^\"]*)"$/ do |url, text|
  response_body.should have_selector("a[href='#{ url }']") do |element|
    element.should contain(text)
  end
end

Then /^the source should contain tag "([^\"]*)" with id "([^\"]*)"$/ do |tag, tagid|
  #response_body.should have_tag(tag, id)
  response_body.should have_selector("#{tag}[id='#{ tagid }']")
end
