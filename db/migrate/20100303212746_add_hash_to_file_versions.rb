class AddHashToFileVersions < ActiveRecord::Migration
  def self.up
    add_column :file_versions, :md5, :string
  end

  def self.down
    remove_column :file_versions, :md5
  end
end
