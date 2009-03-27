class AddIndexForPagePermissions < ActiveRecord::Migration
  def self.up
    add_index :page_permissions, :page_id
  end

  def self.down
    drop_index :page_permissions, :page_id
  end
end
