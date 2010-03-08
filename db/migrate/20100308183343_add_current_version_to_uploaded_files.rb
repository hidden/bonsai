class AddCurrentVersionToUploadedFiles < ActiveRecord::Migration
  def self.up
    add_column :uploaded_files, :current_version_id, :integer, :null => false, :default => 1 
  end

  def self.down
    remove_column :uploaded_files, :current_version_id
  end
end
