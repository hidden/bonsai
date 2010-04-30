Given /there are no files uploaded/ do
  UploadedFile.destroy_all
  FileUtils.rm_rf "shared/upload"
end

When /^I upload "(.*)" file$/ do |file_name|
  visit path_to('/')
  click_link('edit')
  attach_file("file_version_uploaded_data", File.join(Rails.root, 'features', 'fixtures', file_name))
  click_button('Save')
end

When /^I attach the file at "(.*)" to "(.*)"$/ do |path, field|
  attach_file(field, File.join(Rails.root, 'features', 'fixtures', path))
end

When /^I visit "(.*)" frame$/ do |frame_name|
  within 'iframe[name='+frame_name+']' do |frame|
    frame_src = frame.dom.attributes["src"].value
    visit frame_src
  end
end
