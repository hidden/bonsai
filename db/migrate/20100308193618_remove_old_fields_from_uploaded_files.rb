class RemoveOldFieldsFromUploadedFiles < ActiveRecord::Migration
  def self.up
    remove_column :uploaded_files, :size
    remove_column :uploaded_files, :content_type
  end

  def self.down
  end
end
