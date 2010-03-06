require 'fileutils'

Given /there are no files uploaded/ do
  UploadedFile.destroy_all
  FileUtils.rm_rf Path::UP_HISTORY
  FileUtils.rm_rf Path::ANONYM_UPLOAD_PATH
end

When /^I upload "(.*)" file$/ do |file_name|
  visit path_to('/')
  click_link('edit')
  attach_file("uploaded_file_uploaded_data", File.join(Rails.root, 'features', 'fixtures', file_name))
  click_button('Save')
end

When /^I attach the file at "(.*)" to "(.*)"$/ do |path, field|
  attach_file(field, File.join(Rails.root, 'features', 'fixtures', path))
end
