class ChangeUploadedFiles < ActiveRecord::Migration
  def self.up
    change_table :uploaded_files do |t|
      t.remove :size, :content_type, :filename, :page_id
      t.string :attachment_filename
      t.references :page, :null => false
      t.references :current_file_version, :null => false, :default => 0
    end
#    create_table :uploaded_files do |t|
#      t.string :attachment_filename
#      t.references :page, :null => false
#      t.references :current_file_version, :null => false, :default => 0
#
#      t.timestamps
#    end
  end

  def self.down
    drop_table :uploaded_files
  end
end
