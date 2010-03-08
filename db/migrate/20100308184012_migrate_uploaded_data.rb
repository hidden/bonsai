class MigrateUploadedData < ActiveRecord::Migration
  def self.up
    UploadedFile.find_each do |file|
      path = "shared/uploads#{file.page.get_path}" 
      next unless File.exists?(path + file.filename)
      version = FileVersion.new
      version.file = file
      version.uploader_id = file.user_id
      version.content_type = file.content_type
      version.size = File.size(path + file.filename)
      version.created_at = File.ctime(path + file.filename)
      version.save!
      file.current_version = version
      file.save!
      File.mv(path + file.filename, path + version.filename_with_version)
    end
  end

  def self.down
  end
end
