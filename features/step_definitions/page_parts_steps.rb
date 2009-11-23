When /^I add "([^"]*)" page part with text "([^"]*)"$/ do |part_name, text|
  click_link('edit')
  fill_in('new_page_part_name', :with => part_name )
  fill_in('new_page_part_text', :with => text )
  click_button('Add new page part')
end


When /^I edit "([^"]*)" page part with text "([^"]*)"$/ do |part_name, new_name|
  click_link('edit')
  fill_in("parts[#{part_name}]", :with => new_name )
  click_button('Save')
end


When /^I delete "([^"]*)" page part$/ do |part_name|
  click_link('edit')
  check("is_deleted_#{part_name}")
  click_button('Save')
end
