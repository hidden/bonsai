class AddUserToUploadedFiles < ActiveRecord::Migration
  def self.up
    add_column :uploaded_files, :user_id, :integer
  end

  def self.down
    remove_column :uploaded_files, :user_id
  end
end
