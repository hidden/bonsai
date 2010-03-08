class AddIndicesForFastFilesLookup < ActiveRecord::Migration
  def self.up
    add_index :uploaded_files, [:page_id, :filename], :unique => true
    add_index :file_versions, [:file_id, :version], :unique => true
  end

  def self.down
    remove_index :uploaded_files, [:page_id, :filename]
    remove_index :file_versions, [:file_id, :version]
  end
end
