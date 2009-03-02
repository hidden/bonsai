class AddIsDeletedToPagePart < ActiveRecord::Migration
  def self.up
    add_column :page_parts, :is_deleted, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :page_parts, :is_deleted
  end
end
