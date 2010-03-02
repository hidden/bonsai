class DropUploadedFiles < ActiveRecord::Migration
  def self.up
    drop_table :uploaded_files
  end

  def self.down
    create_table :uploaded_files do |t|
      t.integer :size           # file size in bytes
      t.string :content_type    # mime type, ex: application/mp3
      t.string :filename       # sanitized filename
      t.references :page
    end
  end
end