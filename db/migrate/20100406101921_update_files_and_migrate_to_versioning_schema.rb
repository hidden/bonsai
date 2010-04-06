class UpdateFilesAndMigrateToVersioningSchema < ActiveRecord::Migration
  def self.up
    add_column :uploaded_files, :current_file_version_id, :integer, :null => false
    UploadedFile.find_each do |f|
      file = UploadedFile.first(:conditions => {:page_id => f.page_id, :filename => f.filename}, :order => "id DESC")
      f.delete if file != f
      version = FileVersion.find_or_initialize_by_file_id(file.id)
      version.content_type = file.content_type
      version.size = file.size
      version.uploader_id = file.user_id
      version.version = 1
      version.save
      file.update_attribute(:current_file_version_id, version.id)
    end
    remove_columns :uploaded_files, :size, :content_type, :user_id 
  end

  def self.down
    remove_column :uploaded_files, :current_file_version_id
  end
end
