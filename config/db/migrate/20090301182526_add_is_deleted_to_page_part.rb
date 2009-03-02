class AddIsDeletedToPagePart < ActiveRecord::Migration
  def self.up
    add_column :page_parts, :is_deleted, :boolean
  end

  def self.down
    remove_column :page_parts, :is_deleted
  end
end
