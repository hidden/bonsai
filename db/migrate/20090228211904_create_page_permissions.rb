class CreatePagePermissions < ActiveRecord::Migration
  def self.up
    create_table :page_permissions do |t|
      t.references :page, :null => false
      t.references :group, :null => false
      t.boolean :can_view, :null => false
      t.boolean :can_edit, :null => false
      t.boolean :can_manage, :null => false
    end
  end

  def self.down
    drop_table :page_permissions
  end
end
