When /^I load admin group$/ do
  APP_CONFIG['administrators']['admin_group']=2
end

When /^I load admin group with id "([^"]*)"$/ do |id|
  APP_CONFIG['administrators']['admin_group']=id
end

