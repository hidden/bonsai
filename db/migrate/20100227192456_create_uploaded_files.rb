class CreateUploadedFiles < ActiveRecord::Migration
  def self.up
    create_table :uploaded_files do |t|
      t.string :file_name
      t.reference :page, :null => false
      t.reference :current_file_version, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :uploaded_files
  end
end
