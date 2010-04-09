class FileVersion < ActiveRecord::Base
  belongs_to :file, :class_name => "UploadedFile"
  belongs_to :uploader, :class_name => "User"

  def filename_with_path_and_version
    RAILS_ROOT + "/shared/upload" + file.page.get_path + filename_with_version
  end

  def filename_with_path
    RAILS_ROOT + "/shared/upload" + file.page.get_path + file.filename    
  end

  def filename_with_version
    extension = file.extension
    regex = Regexp.new("#{extension.gsub('.', '\.')}$")
    self.file.filename.gsub(regex, "_version#{self.version}#{extension}")
  end
end
