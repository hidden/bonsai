class CreateUploadedFiles < ActiveRecord::Migration
  def self.up
    create_table :uploaded_files do |t|
      t.integer :size           # file size in bytes
      t.string :content_type    # mime type, ex: application/mp3
      t.string :filename       # sanitized filename
      t.references :page
    end
  end

  def self.down
    drop_table :uploaded_files
  end
end
