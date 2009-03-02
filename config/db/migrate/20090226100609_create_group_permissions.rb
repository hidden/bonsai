class CreateGroupPermissions < ActiveRecord::Migration
  def self.up
    create_table :group_permissions do |t|
      t.references :user, :null => false
      t.references :group, :null => false
      t.boolean :can_view, :null => false, :default => false
      t.boolean :can_edit, :null => false, :default => false
    end
  end

  def self.down
    drop_table :group_permissions
  end
end
