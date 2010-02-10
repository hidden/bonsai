class AddUserGroupFlagToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :usergroup, :boolean, :null => false, :default => false
    execute "UPDATE groups g JOIN group_permissions p ON p.group_id = g.id JOIN users u ON u.id = p.user_id SET usergroup = 1 WHERE g.name = u.username"
  end

  def self.down
    remove_column :groups, :usergroup
  end
end
