class FileVersion < ActiveRecord::Base
  belongs_to :file, :class_name => "UploadedFile"
  belongs_to :uploader, :class_name => "User"

  def filename
    file.filename
  end

  def filename_with_version
    name = file.filename
    suffix = "_version#{version}"
    extension = file.extension
    return "#{name}#{suffix}" if extension.blank?
    position = name.rindex(extension)
    name[position] = "#{suffix}."
    name
  end

  def full_filename
    "shared/uploads" + file.page.get_path + filename_with_version
  end

  def newest?
    file.current_version == self
  end

  def rename(name)
    self.filename = name
    self.save
  end

  def exist?(page_path)
    file = Path::UP_HISTORY + page_path + self.filename
    File.file?(file)
  end

  def extension
    File.extname(filename).delete(".").downcase
  end
end
