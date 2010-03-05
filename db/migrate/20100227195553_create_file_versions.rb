class CreateFileVersions < ActiveRecord::Migration
  def self.up
    create_table :file_versions do |t|
      t.integer :size
      t.string :content_type
      t.string :filename
      t.integer :version, :null => false, :default => 1
      t.references :user, :null => false
      t.references :uploaded_file, :null => false

      t.datetime :created_at
    end
  end

  def self.down
    drop_table :file_versions
  end
end
