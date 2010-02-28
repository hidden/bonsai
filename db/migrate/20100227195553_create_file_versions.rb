class CreateFileVersions < ActiveRecord::Migration
  def self.up
    create_table :file_versions do |t|
      t.integer :size
      t.string :content_type
      t.integer :version, :null => false
      t.reference :user, :null => false
      t.reference :uploaded_file, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :file_versions
  end
end
