class CreateFileVersions < ActiveRecord::Migration
  def self.up
    create_table :file_versions do |t|
      t.references :file, :null => false
      t.references :uploader
      t.string :content_type, :null => false
      t.integer :size, :null => false
      t.integer :version, :null => false, :default => 1            
      t.datetime :created_at
    end

    add_index :file_versions, [:file_id, :version], :unique => true
  end

  def self.down
    drop_table :file_versions
  end
end
