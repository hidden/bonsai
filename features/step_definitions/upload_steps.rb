require 'fileutils'

Given /there are no files uploaded/ do
  UploadedFile.destroy_all
  FileUtils.rm_rf 'shared/upload'
end